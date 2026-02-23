# =============================================================================
# OUTPUTS DEL EJEMPLO - MÓDULO VPC
# =============================================================================

# =============================================================================
# INFORMACIÓN DE VPC
# =============================================================================

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.vpc_example.vpc_id
}

output "vpc_cidr_block" {
  description = "Bloque CIDR de la VPC"
  value       = var.cidr_block
}

output "vpc_arn" {
  description = "ARN de la VPC creada"
  value       = module.vpc_example.vpc_id # El módulo base debería exponer el ARN
}

# =============================================================================
# INFORMACIÓN DE SUBREDES PÚBLICAS
# =============================================================================

output "public_subnet_ids" {
  description = "Lista de IDs de las subredes públicas"
  value       = [for subnet in module.vpc_example.subnet_public_info : subnet.id]
}

output "public_subnet_info" {
  description = "Información completa de las subredes públicas"
  value       = module.vpc_example.subnet_public_info
}

output "public_route_table_ids" {
  description = "Lista de IDs de las tablas de enrutamiento públicas"
  value       = [for rt in module.vpc_example.route_table_public_info : rt.id]
}

# =============================================================================
# INFORMACIÓN DE SUBREDES PRIVADAS
# =============================================================================

output "private_subnet_ids" {
  description = "Lista de IDs de las subredes privadas"
  value       = [for subnet in module.vpc_example.subnet_private_info : subnet.id]
}

output "private_subnet_info" {
  description = "Información completa de las subredes privadas"
  value       = module.vpc_example.subnet_private_info
}

output "private_route_table_ids" {
  description = "Lista de IDs de las tablas de enrutamiento privadas"
  value       = [for rt in module.vpc_example.route_table_private_info : rt.id]
}

# =============================================================================
# INFORMACIÓN DE SUBREDES DE BASE DE DATOS
# =============================================================================

output "database_subnet_ids" {
  description = "Lista de IDs de las subredes de base de datos"
  value       = [for subnet in module.vpc_example.subnet_rds_info : subnet.id]
}

output "database_subnet_info" {
  description = "Información completa de las subredes de base de datos"
  value       = module.vpc_example.subnet_rds_info
}

output "database_route_table_ids" {
  description = "Lista de IDs de las tablas de enrutamiento de base de datos"
  value       = [for rt in module.vpc_example.route_table_rds_info : rt.id]
}

# =============================================================================
# INFORMACIÓN DE SECURITY GROUPS (RECURSOS DE EJEMPLO)
# =============================================================================

output "web_security_group_id" {
  description = "ID del Security Group para servidores web"
  value       = aws_security_group.web_sg.id
}

output "app_security_group_id" {
  description = "ID del Security Group para servidores de aplicación"
  value       = aws_security_group.app_sg.id
}

output "database_security_group_id" {
  description = "ID del Security Group para base de datos"
  value       = aws_security_group.db_sg.id
}

# =============================================================================
# INFORMACIÓN DE CONECTIVIDAD
# =============================================================================

output "internet_gateway_id" {
  description = "ID del Internet Gateway (si fue creado)"
  value       = var.create_igw ? "Creado - Ver módulo base para ID específico" : "No creado"
}

output "nat_gateway_info" {
  description = "Información del NAT Gateway (si fue creado)"
  value       = var.create_nat_gateway ? "Creado - Ver módulo base para información específica" : "No creado"
}

# =============================================================================
# INFORMACIÓN PARA INTEGRACIÓN CON OTROS RECURSOS
# =============================================================================

output "availability_zones" {
  description = "Lista de zonas de disponibilidad utilizadas"
  value = distinct(concat(
    [for subnet in var.public_subnets : subnet.availability_zone],
    [for subnet in var.private_subnets : subnet.availability_zone],
    [for subnet in var.database_subnets : subnet.availability_zone]
  ))
}

output "subnet_group_tags" {
  description = "Tags comunes aplicados a los recursos"
  value = {
    client        = var.client
    functionality = var.functionality
    environment   = var.environment
    service       = var.service
    ticket        = var.ticket
  }
}

# =============================================================================
# RESUMEN DE CONFIGURACIÓN
# =============================================================================

output "deployment_summary" {
  description = "Resumen de la implementación realizada"
  value = {
    vpc_cidr              = var.cidr_block
    public_subnets_count  = length(var.public_subnets)
    private_subnets_count = length(var.private_subnets)
    database_subnets_count = length(var.database_subnets)
    internet_gateway      = var.create_igw
    nat_gateway          = var.create_nat_gateway
    region               = var.aws_region
    environment          = var.environment
  }
}
