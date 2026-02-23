# Outputs del ejemplo de implementación del módulo Security Group

output "security_groups_info" {
  description = "Information about all created Security Groups"
  value       = module.security_groups.sg_info
}

output "security_group_ids" {
  description = "IDs of all created Security Groups"
  value = {
    for key, sg in module.security_groups.sg_info : key => sg.sg_id
  }
}

output "security_group_names" {
  description = "Names of all created Security Groups"
  value = {
    for key, sg in module.security_groups.sg_info : key => sg.sg_name
  }
}

output "security_group_arns" {
  description = "ARNs of all created Security Groups"
  value = {
    for key, sg in module.security_groups.sg_info : key => sg.sg_arn
  }
}

output "created_security_groups_summary" {
  description = "Summary of created Security Groups with their applications"
  value = {
    total_security_groups = length(module.security_groups.sg_info)
    security_group_keys   = keys(module.security_groups.sg_info)
    applications = {
      for key, sg in module.security_groups.sg_info : key => sg.application
    }
  }
}

# Outputs específicos para facilitar referencias entre security groups
output "web_servers_sg_id" {
  description = "Security Group ID for web servers"
  value       = try(module.security_groups.sg_info["web-servers"].sg_id, null)
}

output "app_servers_sg_id" {
  description = "Security Group ID for application servers"
  value       = try(module.security_groups.sg_info["app-servers"].sg_id, null)
}

output "db_servers_sg_id" {
  description = "Security Group ID for database servers"
  value       = try(module.security_groups.sg_info["db-servers"].sg_id, null)
}

output "load_balancer_sg_id" {
  description = "Security Group ID for load balancer"
  value       = try(module.security_groups.sg_info["load-balancer"].sg_id, null)
}
