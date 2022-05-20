output "az1" {
    value = module.vpc.azs
}
output "vpc-id" {
    description = "vpc id"
    value = module.vpc.vpc_id
}