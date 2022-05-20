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
    source = "github.com/Ashutosh-aws/terraform.git"
}

resource "aws_db_subnet_group" "private-subnet-group" {
  name       = "main"
  subnet_ids = [module.vpc.private_ip, module.vpc.private_ip1]

  tags = {
    Name = "My DB subnet group"
  }
}

#cluster mysql
resource "aws_rds_cluster" "rds_cluster" {

    cluster_identifier = var.cluster_name
    engine = var.engine_name
    engine_version = var.engine_v
    availability_zones = module.vpc.az
    database_name = var.db_name
    master_username = var.master_user
    master_password = var.master_pass
    #engine_mode = "multimaster"
    backup_retention_period = var.retention_period
    preferred_backup_window = var.backup_window
    skip_final_snapshot  = true
    db_subnet_group_name = aws_db_subnet_group.private-subnet-group.name
    apply_immediately = true
 

   
}
#cluster instance
resource "aws_rds_cluster_instance" "cluster_instance" {
    count = 2
    identifier = "tf-aurora-cluster-demo-${count.index}"
    cluster_identifier = aws_rds_cluster.rds_cluster.id
    instance_class = "db.t3.small"
    engine = aws_rds_cluster.rds_cluster.engine
    engine_version = aws_rds_cluster.rds_cluster.engine_version
}
