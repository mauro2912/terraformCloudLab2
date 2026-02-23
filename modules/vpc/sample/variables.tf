# =============================================================================
# VARIABLES COMUNES
# =============================================================================

variable "client" {
  description = "Nombre del cliente"
  type        = string
  
  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 20
    error_message = "El nombre del cliente debe tener entre 1 y 20 caracteres."
  }
}

variable "functionality" {
  description = "Funcionalidad del recurso"
  type        = string
  
  validation {
    condition     = length(var.functionality) > 0 && length(var.functionality) <= 20
    error_message = "La funcionalidad debe tener entre 1 y 20 caracteres."
  }
}

variable "environment" {
  description = "Ambiente (dev, test, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "El ambiente debe ser uno de: dev, test, prod."
  }
}

variable "service" {
  description = "Nombre del servicio"
  type        = string
  
  validation {
    condition     = length(var.service) > 0 && length(var.service) <= 20
    error_message = "El nombre del servicio debe tener entre 1 y 20 caracteres."
  }
}

variable "ticket" {
  description = "ID del ticket o caso"
  type        = string
  
  validation {
    condition     = length(var.ticket) > 0
    error_message = "El ID del ticket no puede estar vacío."
  }
}

variable "aws_region" {
  description = "Región de AWS donde desplegar los recursos"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1", "ap-southeast-1",
      "ap-southeast-2", "ap-northeast-1", "sa-east-1"
    ], var.aws_region)
    error_message = "La región debe ser una región válida de AWS."
  }
}

# =============================================================================
# VARIABLES DE CONFIGURACIÓN DE RED
# =============================================================================

variable "cidr_block" {
  description = "Bloque CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "El bloque CIDR debe ser válido (ej: 10.0.0.0/16)."
  }
}

variable "instance_tenancy" {
  description = "Tenencia de instancias (default/dedicated)"
  type        = string
  default     = "default"
  
  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "La tenencia debe ser 'default' o 'dedicated'."
  }
}

variable "enable_dns_support" {
  description = "Habilitar soporte DNS en la VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Habilitar hostnames DNS en la VPC"
  type        = bool
  default     = true
}

# =============================================================================
# VARIABLES DE SUBREDES (OPCIONALES - CON VALORES POR DEFECTO)
# =============================================================================

variable "public_subnets" {
  description = "Lista de configuraciones para subredes públicas"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    service           = string
  }))
  default = [
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      service           = "alb"
    },
    {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
      service           = "alb"
    }
  ]
}

variable "private_subnets" {
  description = "Lista de configuraciones para subredes privadas"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    service           = string
  }))
  default = [
    {
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-east-1a"
      service           = "app"
    },
    {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1b"
      service           = "app"
    }
  ]
}

variable "database_subnets" {
  description = "Lista de configuraciones para subredes de base de datos"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    service           = string
  }))
  default = [
    {
      cidr_block        = "10.0.20.0/24"
      availability_zone = "us-east-1a"
      service           = "mysql"
    },
    {
      cidr_block        = "10.0.21.0/24"
      availability_zone = "us-east-1b"
      service           = "mysql"
    }
  ]
}

# =============================================================================
# VARIABLES DE GATEWAY
# =============================================================================

variable "create_igw" {
  description = "Crear Internet Gateway (true/false)"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Crear NAT Gateway (true/false)"
  type        = bool
  default     = true
}
