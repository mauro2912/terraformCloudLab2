###########################################
#Common variables
###########################################
variable "client" {
  description = "Client name"
  type        = string
  
  validation {
    condition     = length(var.client) > 0
    error_message = "Client name cannot be empty."
  }
}

variable "functionality" {
  description = "Functionality of the resource"
  type        = string
  
  validation {
    condition     = length(var.functionality) > 0
    error_message = "Functionality cannot be empty."
  }
}

variable "environment" {
  description = "Environment (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn."
  }
}

variable "service" {
  description = "Service name"
  type        = string
  
  validation {
    condition     = length(var.service) > 0
    error_message = "Service name cannot be empty."
  }
}

variable "ticket" {
  description = "Ticket or case ID"
  type        = string
  
  validation {
    condition     = length(var.ticket) > 0
    error_message = "Ticket ID cannot be empty."
  }
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "instance_tenancy" {
  description = "Instance tenancy (default or dedicated)"
  type        = string
  default     = "default"
  
  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "Instance tenancy must be 'default' or 'dedicated'."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}


##########################
#Subnet variables
##########################

variable "public_cidr_blocks" {
  description = "Configuration for public subnets"
  type = list(object({
    ticket            = string  # Ticket or case ID for traceability
    cidr_block        = string  # CIDR block for the subnet (e.g., "10.0.1.0/24")
    availability_zone = string  # AWS availability zone (e.g., "us-east-1a")
    service           = string  # Service name (e.g., "web", "app")
    accessclass       = string  # Access classification ("public" or "private")
  }))
  
  validation {
    condition = alltrue([
      for subnet in var.public_cidr_blocks : can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All CIDR blocks must be valid CIDR notation."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.public_cidr_blocks : subnet.accessclass == "public"
    ])
    error_message = "All subnets in public_cidr_blocks must have accessclass = 'public'."
  }
}


variable "private_cidr_blocks" {
  description = "Configuration for private subnets"
  type = list(object({
    ticket            = string  # Ticket or case ID for traceability
    cidr_block        = string  # CIDR block for the subnet (e.g., "10.0.10.0/24")
    availability_zone = string  # AWS availability zone (e.g., "us-east-1a")
    service           = string  # Service name (e.g., "app", "backend")
    accessclass       = string  # Access classification ("public" or "private")
  }))
  
  validation {
    condition = alltrue([
      for subnet in var.private_cidr_blocks : can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All CIDR blocks must be valid CIDR notation."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.private_cidr_blocks : subnet.accessclass == "private"
    ])
    error_message = "All subnets in private_cidr_blocks must have accessclass = 'private'."
  }
}
variable "rds_cidr_blocks" {
  description = "Configuration for database subnets"
  type = list(object({
    ticket            = string  # Ticket or case ID for traceability
    cidr_block        = string  # CIDR block for the subnet (e.g., "10.0.20.0/24")
    availability_zone = string  # AWS availability zone (e.g., "us-east-1a")
    service           = string  # Service name (e.g., "mysql", "postgres")
    accessclass       = string  # Access classification ("private" for databases)
  }))
  
  validation {
    condition = alltrue([
      for subnet in var.rds_cidr_blocks : can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All CIDR blocks must be valid CIDR notation."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.rds_cidr_blocks : subnet.accessclass == "private"
    ])
    error_message = "All subnets in rds_cidr_blocks must have accessclass = 'private'."
  }
}

#############################
# Gateway variables
#############################
variable "create_igw" {
  description = "Create Internet Gateway (1=yes, 0=no)"
  type        = number
  
  validation {
    condition     = contains([0, 1], var.create_igw)
    error_message = "create_igw must be 0 (no) or 1 (yes)."
  }
}

variable "nat_config" {
  description = "Configuration for NAT Gateway"
  type = list(object({
    subnet_id = string  # ID of the public subnet where NAT Gateway will be created
  }))
  default = []
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
