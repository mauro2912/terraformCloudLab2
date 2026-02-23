output "vpc_id" {
  description = "ID of the VPC created"
  value       = aws_vpc.main.id
}

output "subnet_public_info" {
  description = "Complete information of the public subnets"
  value       = module.public_subnets.subnet_info
}

output "route_table_public_info" {
  description = "Information of the public route tables"
  value       = module.public_subnets.route_table_info
}

output "subnet_private_info" {
  description = "Complete information of the private subnets"
  value       = module.private_subnets.subnet_info
}

output "route_table_private_info" {
  description = "Information of the private route tables"
  value       = module.private_subnets.route_table_info
}

output "subnet_rds_info" {
  description = "Complete information of the database subnets"
  value       = module.database_subnets.subnet_info
}

output "route_table_rds_info" {
  description = "Information of the database route tables"
  value       = module.database_subnets.route_table_info
}