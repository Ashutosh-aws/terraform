terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id
  depends_on = [
    module.vpc
  ]
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_spot_instance_request" "pritunl" {
  ami           = "ami-05ba3a39a75be1ec4"
  spot_price    = "0.0045"
  instance_type = "t3a.small"
  key_name = "ashutosh-dev"
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.allow_tls.id}"]
  wait_for_fulfillment = true
  depends_on = [
    module.vpc
  ]
  tags = {
    "Name" = "CheapWorker"
  }

   provisioner "remote-exec" {
   inline = [
     "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "echo  'deb http://repo.pritunl.com/stable/apt focal main' | sudo tee /etc/apt/sources.list.d/pritunl.list",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -",
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 9DA31620334BD75D9DCB49F368818C72E52529D4",
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A",
      "sudo apt -y install pritunl mongodb-org",
      "curl https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo apt-key add -",
      "sudo apt-get update",
      "sudo apt-get -y install pritunl mongodb-org",
      "sudo systemctl enable mongod pritunl",
      "sudo systemctl start mongod pritunl",
      "sleep 20",
      "sudo pritunl set-mongodb mongodb://localhost:27017/pritunl",

      "sudo pritunl setup-key >> credential.txt",
      "sleep 60",
      "sudo pritunl default-password >> credential.txt"
   ]
  }
  
  connection {
    type = "ssh"
    user = "ubuntu"
    host = aws_spot_instance_request.pritunl.public_ip
    private_key =  file("../../../../Downloads/ashutosh-dev.pem")
  }
}
resource "null_resource" "asb" {
  depends_on = [
    aws_spot_instance_request.pritunl
  ]
  provisioner "local-exec" {
   command =  "scp -o StrictHostKeyChecking=no -i  ../../../../Downloads/ashutosh-dev.pem ubuntu@${aws_spot_instance_request.pritunl.public_ip}:/home/ubuntu/credential.txt ."
  
  }
  
}


