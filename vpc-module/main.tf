terraform {
  cloud {
    organization = "squareops-dev"

    workspaces {
      name = "ashutosh-dev"
    }
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
    region = "ap-south-1" 
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  single_nat_gateway = true
  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true
  tags = {
    Terraform = "true"
    Environment = "dev"
   
  }
}
