variable "client" {
  description = "Client name identifier"
  type        = string
}

variable "functionality" {
  description = "Functionality or specific project identifier"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn."
  }
}

variable "sg_config" {
  description = "Configuration for Security Groups organized by unique key"
  type = map(object({
    ticket      = string
    description = string
    vpc_id      = string
    application = string
    accessclass = string
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      description     = string
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
  }))
  
  validation {
    condition = alltrue([
      for k, v in var.sg_config : 
      can(regex("^[a-zA-Z0-9-_]+$", k))
    ])
    error_message = "Security group keys must contain only alphanumeric characters, hyphens, and underscores."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.sg_config : alltrue([
        for ingress in v.ingress : 
        contains(["tcp", "udp", "icmp", "all", "-1"], ingress.protocol)
      ])
    ])
    error_message = "Ingress protocol must be one of: tcp, udp, icmp, all, -1."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.sg_config : alltrue([
        for egress in v.egress : 
        contains(["tcp", "udp", "icmp", "all", "-1"], egress.protocol)
      ])
    ])
    error_message = "Egress protocol must be one of: tcp, udp, icmp, all, -1."
  }
}
