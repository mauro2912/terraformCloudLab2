# =============================================================================
# EJEMPLO DE IMPLEMENTACIÓN - MÓDULO VPC
# =============================================================================
# Este archivo demuestra cómo usar el módulo transer-iac-tf-mod-vpc
# para crear una VPC con arquitectura de 3 capas

# =============================================================================
# CONFIGURACIÓN LOCAL PARA TRANSFORMAR VARIABLES
# =============================================================================

locals {
  # Transformar configuración de subredes públicas al formato esperado por el módulo
  public_cidr_blocks = [
    for subnet in var.public_subnets : {
      ticket            = var.ticket
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      service           = subnet.service
      accessclass       = "public"
    }
  ]
  
  # Transformar configuración de subredes privadas al formato esperado por el módulo
  private_cidr_blocks = [
    for subnet in var.private_subnets : {
      ticket            = var.ticket
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      service           = subnet.service
      accessclass       = "private"
    }
  ]
  
  # Transformar configuración de subredes de base de datos al formato esperado por el módulo
  rds_cidr_blocks = [
    for subnet in var.database_subnets : {
      ticket            = var.ticket
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      service           = subnet.service
      accessclass       = "private"
    }
  ]
  
  # Configuración de NAT Gateway (solo si se habilita)
  nat_config = var.create_nat_gateway ? [
    {
      subnet_id = module.vpc_example.subnet_public_info[0].id
    }
  ] : []
}

# =============================================================================
# MÓDULO VPC - IMPLEMENTACIÓN PRINCIPAL
# =============================================================================

module "vpc_example" {
  # Usar el módulo local (en producción usar referencia a repositorio git)
  source = "../"
  
  # Variables comunes requeridas
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  service       = var.service
  ticket        = var.ticket

  # Configuración de VPC
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  # Configuración de subredes (usando locals transformados)
  public_cidr_blocks  = local.public_cidr_blocks
  private_cidr_blocks = local.private_cidr_blocks
  rds_cidr_blocks     = local.rds_cidr_blocks

  # Configuración de gateways
  create_igw = var.create_igw ? 1 : 0
  nat_config = local.nat_config
}

# =============================================================================
# RECURSOS ADICIONALES DE EJEMPLO (OPCIONAL)
# =============================================================================

# Ejemplo: Security Group para servidores web en subredes públicas
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.client}-${var.functionality}-${var.environment}-sg-web"
  description = "Security group para servidores web - Ejemplo"
  vpc_id      = module.vpc_example.vpc_id

  # Permitir tráfico HTTP desde Internet
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico HTTPS desde Internet
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico saliente
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.client}-${var.functionality}-${var.environment}-sg-web"
    id_case     = var.ticket
    accessclass = "public"
  }
}

# Ejemplo: Security Group para servidores de aplicación en subredes privadas
resource "aws_security_group" "app_sg" {
  name_prefix = "${var.client}-${var.functionality}-${var.environment}-sg-app"
  description = "Security group para servidores de aplicación - Ejemplo"
  vpc_id      = module.vpc_example.vpc_id

  # Permitir tráfico desde el security group web
  ingress {
    description     = "HTTP from Web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # Permitir todo el tráfico saliente
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.client}-${var.functionality}-${var.environment}-sg-app"
    id_case     = var.ticket
    accessclass = "private"
  }
}

# Ejemplo: Security Group para base de datos
resource "aws_security_group" "db_sg" {
  name_prefix = "${var.client}-${var.functionality}-${var.environment}-sg-db"
  description = "Security group para base de datos - Ejemplo"
  vpc_id      = module.vpc_example.vpc_id

  # Permitir tráfico MySQL desde el security group de aplicación
  ingress {
    description     = "MySQL from App tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name        = "${var.client}-${var.functionality}-${var.environment}-sg-db"
    id_case     = var.ticket
    accessclass = "private"
  }
}
