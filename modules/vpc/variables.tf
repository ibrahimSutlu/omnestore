variable "cidr_block" {}
variable "azs" {}
variable "public_subnets" {}
variable "private_app_subnets" {}
variable "private_data_subnets" {}
variable "admin_ip" {}

variable "project_name" {
  default = "omnistore"
}
