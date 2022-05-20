variable "cluster_name" {
    type =   string
    default = "tf-aurora-mysql-multi-master"  
}
variable "engine_name" {
    type = string
    default = "aurora-mysql"
}
variable "db_name" {
    type = string
    default = "kenzinda"
}
variable "master_user" {
    type = string
    default = "admin"  
}
variable "master_pass" {
    type = string
    sensitive = true  
    default = "squareops"
}
variable "retention_period" {
    type = string
    default = "1"  
}
variable "backup_window" {
    type = string
    default = "07:00-07:30"
}
variable "engine_v" {
    type = string
    default = "5.7.mysql_aurora.2.03.2"
  
}