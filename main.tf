terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  bastion_ssh_private_key = var.bastion_ssh_private_key

  cidr_block = "10.0.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.4.0/24"
  ]

  private_app_subnets = [
    "10.0.2.0/24",
    "10.0.5.0/24"
  ]

  private_data_subnets = [
    "10.0.3.0/24",
    "10.0.6.0/24"
  ]

  admin_ip = "109.228.198.80/32"
}




