output "VPC-name" {
  value = aws_vpc.main.tags
}
output "public_subnets" {
  description = "List of cidr_blocks of public subnets"
  value       = var.public_enable ? aws_subnet.PublicSubnet[*].cidr_block : (var.public_enable ? null : aws_subnet.PublicSubnet[*].cidr_block)
}
output "private_subnets" {
  description = "List of cidr_blocks of public subnets"
  value       = var.private_enable ? aws_subnet.PrivateSubnet[*].cidr_block : (var.private_enable ? null : aws_subnet.PrivateSubnet[*].cidr_block)
}
/* output "public_subnets_2_CIDR" {
  description = "List of cidr_blocks of public subnets"
  value       = var.public_enable == "yes" ? aws_subnet.PublicSubnet[1].cidr_block : null 
}
output "public_subnets_3_CIDR" {
  description = "List of cidr_blocks of public subnets"
  value       = var.public_enable == "yes" ? aws_subnet.PublicSubnet[2].cidr_block : null 
} */
/*
output "private_subnets_1_CIDR" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.PrivateSubnet-1.cidr_block
}
output "Private_subnets_2_CIDR" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.PrivateSubnet-2.cidr_block
}
output "Security_group" {
    description = "Ingress value of SG"
    value = aws_security_group.security-group.id
}
output "private_ip" {
  value = aws_subnet.PrivateSubnet-1.id
}
output "private_ip1" {
  value = aws_subnet.PrivateSubnet-2.id  
} */
# output "az" {
#   value = aws_instance.ubuntu.availability_zone.names
# }