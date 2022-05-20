/* terraform {
  cloud {
    organization = "squareops-dev"

    workspaces {
      name = "ashutosh-dev"
    }
  }
} */
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {

  region = "ap-south-1"
}

# terraform {
#   backend "s3" {
#     bucket = "tfstate-ashutosh"
#     key    = "state file/terraform.tfstate"
#     region = "ap-south-1"
#     dynamodb_table = "state-lock_tf"
#   }
# }
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = var.dns_resolution
  enable_dns_hostnames = var.dns_resolution
  tags = {
    Name = "${var.tags}-ashutosh"
  }
}

data "aws_availability_zones" "available" {
  state                  = "available"
  all_availability_zones = true
}


resource "aws_subnet" "PublicSubnet" { #public subnet 1
  vpc_id = aws_vpc.main.id

  count = var.public_enable ? var.required_subnet : (var.public_enable ? 0 : 1)

  cidr_block = cidrsubnet(var.cidr, 8, count.index)

  availability_zone = data.aws_availability_zones.available.names[[element(var.test, count.index)]] //"${count.index > 3 ?  data.aws_availability_zones.available.names[count.index - count.index] : data.aws_availability_zones.available.names[count.index]}"



  map_public_ip_on_launch = var.assign_public_ip

  tags = {
    Name = "${var.tags}-publicSubnet1-${count.index}"
  }
}

resource "aws_subnet" "PrivateSubnet" { #private subnet 1
  vpc_id = aws_vpc.main.id

  count = var.private_enable ? var.required_subnet : (var.private_enable ? 0 : 1)

  cidr_block              = cidrsubnet(var.cidr, 8, count.index + var.required_subnet)
  availability_zone       = data.aws_availability_zones.available.names[[element(var.test, count.index)]]
  map_public_ip_on_launch = var.assign_public_ip

  tags = {
    Name = "${var.tags}-privateSubnet-${count.index}"
  }
}
/* resource "aws_subnet" "PublicSubnet-2" {   #public Subnet 2
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(var.cidr , 8 , 1)
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = var.assign_public_ip

    tags = {
      Name = "${var.tags}-PublicSubnet2"
  }
}
resource "aws_subnet" "PrivateSubnet-1" {   #private subnet 1
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(var.cidr , 8 , 2)
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
      Name = "${var.tags}-PrivateSubnet1"
  }
}
resource "aws_subnet" "PrivateSubnet-2" {    #private subnet 2
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(var.cidr , 8 , 3)
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
      Name = "${var.tags}-PrivateSubnet2"
  }
}*/

resource "aws_internet_gateway" "IGW" { #internet gateway attachment
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tags}-IGW"
  }
}

/* resource "aws_internet_gateway_attachment" "IGW-attachment" {   # igw attachemnt with vpc
  internet_gateway_id = aws_internet_gateway.IGW.id
  vpc_id              = aws_vpc.main.id
} */

resource "aws_eip" "eip123" { # elastic ip for nat gateway
  vpc = true
  tags = {
    Name = "${var.tags}-eip-NAT"
  }
}

resource "aws_nat_gateway" "nat123" {
  allocation_id = aws_eip.eip123.allocation_id
  subnet_id     = aws_subnet.PublicSubnet[0].id

  tags = {
    Name = "${var.tags}-NAT"
  }

  # depends_on = [aws_internet_gateway.IGW]
}

resource "aws_route_table" "PublicRouteTable" { #public route table
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "${var.tags}-Public-Route-Table"
  }
}
resource "aws_route_table" "PrivateRouteTable" { #Private route table
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat123.id
  }
  tags = {
    Name = "${var.tags}-Private-Route-Table"
  }
}

resource "aws_route_table_association" "route-pb1" {
  count          = length(aws_subnet.PublicSubnet[*].cidr_block)
  route_table_id = aws_route_table.PublicRouteTable.id
  subnet_id      = element(aws_subnet.PublicSubnet.*.id, count.index)
  depends_on     = [aws_route_table.PublicRouteTable]
}

/* resource "aws_route_table_association" "route-pb2" {
  route_table_id            = aws_route_table.PublicRouteTable.id
  subnet_id = aws_subnet.PublicSubnet-2.id
  depends_on                = [aws_route_table.PublicRouteTable]
} */
/* resource "aws_route_table_association" "route-pr1" {
  route_table_id            = aws_route_table.PrivateRouteTable.id
  subnet_id = aws_subnet.PrivateSubnet-1.id
  depends_on                = [aws_route_table.PrivateRouteTable]
} */

/* resource "aws_route_table_association" "route-pr2" {
  route_table_id            = aws_route_table.PrivateRouteTable.id
  subnet_id = aws_subnet.PrivateSubnet-2.id
  depends_on                = [aws_route_table.PrivateRouteTable]
} */
/*
resource "aws_security_group" "security-group" {      # security group vpc
  name        = "my custom vpc security group"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "ssh "
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_traffic"
  }
} */

# resource "aws_instance" "ubuntu" {
#     ami = "ami-0851b76e8b1bce90b"
#     instance_type = "t3a.small"
#     subnet_id = aws_subnet.PublicSubnet-1.id
#     availability_zone = data.aws_availability_zones.available.state
#     key_name = "Ashutosh-aws"
#    # security_group_id = aws_security_group.security-group.id
#     tags = {
#       Name = "tf.ubuntu.ashutosh"
#  }
# }
# resource "aws_network_interface_sg_attachment" "sg_attachment" {
#   security_group_id    = aws_security_group.security-group.id
#   network_interface_id = aws_instance.ubuntu.primary_network_interface_id
# }

