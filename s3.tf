############################
# RANDOM SUFFIX
############################

resource "random_id" "suffix" {
  byte_length = 4
}
data "aws_acm_certificate" "frontend" {
  provider    = aws.us_east_1
  domain      = "omnestore.org"
  statuses    = ["ISSUED"]
  most_recent = true
}
############################
# S3 BUCKET (SENİN KODUN)
resource "aws_s3_bucket" "frontend" {
  bucket = "omnestore-frontend-prod"

  tags = {
    Name = "OmniStore-Frontend"
  }
}




resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}


data "aws_route53_zone" "main" {
  name         = "omnestore.org."
  private_zone = false
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "omnestore.org"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.omnestore.org"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

############################
# CLOUDFRONT (UPDATED)
############################
resource "aws_cloudfront_distribution" "frontend" {
  enabled         = true
  is_ipv6_enabled = true

  default_root_object = "index.html"

  ############################
  # 2️⃣ ALTERNATE DOMAIN NAMES
  ############################
  aliases = [
    "omnestore.org",
    "www.omnestore.org"
  ]

  ############################
  # 1️⃣ ORIGIN – S3 WEBSITE
  ############################
  origin {
    domain_name = aws_s3_bucket_website_configuration.frontend.website_endpoint
    origin_id   = "s3-frontend-origin"

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
    target_origin_id = "s3-frontend-origin"

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

############################
# OUTPUTS
############################
output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}