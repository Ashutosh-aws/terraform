provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_spot_instance_request" "cheap_worker" {
  ami           = "ami-05ba3a39a75be1ec4"
  spot_price    = "0.004"
  instance_type = "t3a.small"
  key_name = "Ashutosh-aws"
  user_data = "${file("prit.sh")}"

  tags = {
    "Name" = "CheapWorker"
  }
}
