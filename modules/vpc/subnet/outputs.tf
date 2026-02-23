output "subnet_info" {
  value = [for subnet in aws_subnet.main_subnet : {"subnet_id" : subnet.id, "subnet_cidr" : subnet.cidr_block, "subnet_name" : subnet.tags_all.Name}]
}


output "route_table_info" {
  value = [for route_table in aws_route_table.route_table : {"route_table_id" : route_table.id, "route_table_name" : route_table.tags_all.Name}]
}

