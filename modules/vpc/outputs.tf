output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}