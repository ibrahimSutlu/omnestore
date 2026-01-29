resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
#SUBNETS
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnets)

  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_app_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-private-app-${count.index + 1}"
  }
}


resource "aws_subnet" "private_data" {
  count = length(var.private_data_subnets)

  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_data_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-private-data-${count.index + 1}"
  }
}

#############################################
# AWS instance 
resource "aws_instance" "my_instance" {
  ami           = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet[0].id
  security_groups = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.omnistore_key.key_name

  source_dest_check = false
  tags = {
    Name = "tf-example"
  }
  user_data = <<-EOF
    #!/bin/bash
    set -e

    ##################################
    # 1️⃣ MEVCUT NAT AYARLARI (DOKUNMADIK)
    ##################################

    echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
    sysctl -p

    sudo iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
    sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -j ACCEPT

    ##################################
    # 2️⃣ SSH KEY OLUŞTUR (YENİ EK)
    ##################################

    USER=ubuntu
    SSH_DIR=/home/$USER/.ssh

    mkdir -p $SSH_DIR
    chmod 700 $SSH_DIR

    cat <<'KEY' > $SSH_DIR/omnistore-key
    ${var.bastion_ssh_private_key}
    KEY

    chmod 600 $SSH_DIR/omnistore-key
    chown -R $USER:$USER $SSH_DIR

    ##################################
    # DONE
    ##################################
    EOF
}

resource "aws_instance" "myprivate_instance" {
  ami           = "ami-0c398cb65a93047f2"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_app[0].id
  security_groups = [aws_security_group.private_ec2_sg.id]
  associate_public_ip_address = false
  key_name = aws_key_pair.omnistore_key.key_name

  source_dest_check = false
  tags = {
    Name = "tf-private-example"
  }
user_data = <<-EOF
      #!/bin/bash
      set -eux

      # NAT üzerinden internet gelene kadar bekle
      until curl -s --head http://archive.ubuntu.com | grep "200 OK"; do
        echo "Waiting for NAT internet access..."
        sleep 5
      done

      # Paket listesi
      sudo apt-get update -y

      # NGINX kur
      sudo apt-get install -y nginx

      # Servisi başlat ve kalıcı yap
      sudo systemctl start nginx
      sudo systemctl enable nginx

      # Test sayfası
      cat <<HTML > /var/www/html/index.html
      <!DOCTYPE html>
      <html>
      <head>
        <title>OmniStore</title>
      </head>
      <body>
        <h1>HELLO FROM OMNISTORE (NGINX)</h1>
      </body>
      </html>
      HTML

      # NGINX reload
      sudo systemctl reload nginx
      EOF
}
#############################################
# SECURITY GROUP instance 
resource "aws_security_group" "private_ec2_sg" {
  name        = "${var.project_name}-PRIVATE-EC2-SG"
  description = "Security Group for Private EC2 instances"
  vpc_id      = aws_vpc.my_vpc.id

  # SSH sadece NAT Instance'tan
  ingress {
    description     = "SSH from NAT Instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.my_security_group.id]
  }
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  # (Opsiyonel) ICMP - debug için
  ingress {
    description = "ICMP from NAT"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr_block]
  }

  # Outbound serbest (NAT üzerinden çıkış)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-PRIVATE-EC2-SG"
  }
}
# 2. NAT Security Group (Bilinçli ve Minimal)
resource "aws_security_group" "my_security_group" {
  name        = "${var.project_name}-NAT-SG"
  description = "Security Group for NAT Instance"
  vpc_id      = aws_vpc.my_vpc.id

  # --- INBOUND KURALLARI (İçeri Giren) ---

  # 1. SSH: Sadece Admin IP'den (Yönetim için)
  ingress {
    description = "SSH from Admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 2. HTTP (80): Sadece VPC içinden (Güncellemeler için)
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  # 3. HTTPS (443): Sadece VPC içinden (API çağrıları, Docker pull için)
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  # 4. ICMP: Ping testleri için (Opsiyonel ama yararlı)
  ingress {
    description = "ICMP from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr_block]
  }

  # --- OUTBOUND KURALLARI (Dışarı Çıkan) ---

  # 1. İnternet: NAT görevi gereği her yere çıkış serbest
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-NAT-SG"
  }
}
#############################################
# INTERNET GATEWAY
resource "aws_key_pair" "omnistore_key" {
    key_name   = "omnistore-key"
    public_key = file("~/.ssh/omnistore-key.pub")
  }
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.project_name}-my_igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    # HEDEF: Tüm internet (Dünyadaki herhangi bir IP)
    cidr_block = "0.0.0.0/0"
    
    # YÖNLENDİRİLECEK YER: NAT Instance'ın Ağ Kartı (ENI)
    # Burası kritik! Instance ID değil, Network Interface ID kullanıyoruz.
    network_interface_id = aws_instance.my_instance.primary_network_interface_id
  }
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_eip_association" "nat_eip_assoc" {
  instance_id   = aws_instance.my_instance.id
  allocation_id = aws_eip.my_eip.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_app_assoc" {
  count          = length(aws_subnet.private_app)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_data_assoc" {
  count          = length(aws_subnet.private_data)
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# NAT GATEWAY

# ALB 

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-sg-alb"
  description = "ALB inbound from Internet"
  vpc_id      =  aws_vpc.my_vpc.id  # senin vpc module outputuna göre düzenle

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "omnistore_alb" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets = aws_subnet.public_subnet[*].id
  security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   =  aws_vpc.my_vpc.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.omnistore_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.omnistore_alb.dns_name
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.myprivate_instance.id
  port             = 80
}

#############################################
resource "aws_eip" "my_eip" {
  vpc = true

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}


#####AWS ACM CERTIFICATE#####
data "aws_route53_zone" "main" {
  name         = "omnestore.org"
  private_zone = false
}


data "aws_acm_certificate" "frontend" {
  provider    = aws.us_east_1
  domain      = "omnestore.org"
  statuses    = ["ISSUED"]
  most_recent = true
}
resource "aws_cloudfront_distribution" "frontend" {
  enabled         = true
  is_ipv6_enabled = true

  #  default_root_object = "index.html"

  ############################
  # 2️⃣ ALTERNATE DOMAIN NAMES
  ############################
  aliases = [
    "omnestore.org",
    "www.omnestore.org"
  ]

  ############################
  # 1️⃣ ORIGIN – S3 WEBSITE
  origin {
    domain_name = aws_lb.omnistore_alb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  ############################
  # 3️⃣ SSL CERTIFICATE (ACM)
  ############################
  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.frontend.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
resource "aws_route53_record" "root_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "omnestore.org"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}
output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}
