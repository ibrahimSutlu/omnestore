
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "aws_alias" {
  type    = string
  default = "us_east_1"
}
variable "bastion_ssh_private_key" {
  description = "Private SSH key for bastion to access private EC2"
  type        = string
  sensitive   = true
}

