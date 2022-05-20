output "cluster_name" {
    description = "cluster identifier"
    value = aws_rds_cluster.rds_cluster.cluster_identifier
}
output "az1" {
    description = "availability zone of cluster"
    value = aws_rds_cluster.rds_cluster.availability_zones
}
output "database_n" {
    description = "name of database"
    value = aws_rds_cluster.rds_cluster.database_name  
}
# output "instance-ip" {
#     description = "cluster instance endpoint"
#     value = aws_rds_cluster_instance.cluster_instance.endpoint
  
# }
# output "port-number" {
#     description = "port for cluster instance"
#     value = aws_rds_cluster_instance.cluster_instance.port
  
# }
# output "instance-class" {
#     description = "instance class of cluster instance"
#     value = aws_rds_cluster_instance.cluster_instance.instance_class
# }