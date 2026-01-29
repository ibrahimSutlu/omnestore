variable "cidr_block" {}
variable "azs" {}
variable "public_subnets" {}
variable "private_app_subnets" {}
variable "private_data_subnets" {}
variable "admin_ip" {}


variable "project_name" {
  default = "omnistore"
}

variable "bastion_ssh_private_key" {
  description = "Private SSH key for bastion to access private EC2"
  type        = string
  sensitive   = true
}
