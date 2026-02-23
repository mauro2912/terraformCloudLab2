variable "client" {
  description = "Client name"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.client))
    error_message = "Client must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition     = length(var.client) > 0
    error_message = "Client name cannot be empty."
  }
}


variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "qa", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, staging, qa, pdn."
  }
}

variable "application" {
  description = "Application name for resource identification"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.application))
    error_message = "Application must contain only alphanumeric characters, hyphens, and underscores."
  }
  
  validation {
    condition     = length(var.application) > 0
    error_message = "Application name cannot be empty."
  }
}

variable "s3_config" {
  description = "Configuration for S3 buckets organized by unique key"
  type = map(object({
    kms_key_id = string                           # KMS key ID for bucket encryption
    accessclass = string                           # Access classification (private, public, restricted)
    versioning = string                           # Versioning status (Enabled, Suspended, Disabled)
    additional_tags = optional(map(string), {})        # Additional tags for the bucket
    lambda_notifications = optional(list(object({
      # Lambda notification configurations
      lambda_function_arn = string                         # ARN of the Lambda function
      events = list(string)                    # S3 events that trigger the notification
      filter_prefix = optional(string, "")           # Object key prefix filter
      filter_suffix = optional(string, "")           # Object key suffix filter
    })), [])
    statements = optional(list(object({
      # IAM policy statements for bucket policy
      sid = string                                 # Statement ID
      actions = list(string)                          # List of allowed actions
      resources = list(string)                          # List of resource ARNs
      effect = string                                # Allow or Deny
      type = string                                # Principal type (AWS, Service, etc.)
      identifiers = list(string)                          # Principal identifiers
      condition = optional(list(object({
        # Condition blocks for the statement
        test = string                                 # Condition test (StringEquals, IpAddress, etc.)
        variable = string                                 # Condition variable
        values = list(string)                          # Condition values
      })), [])
    })), [])
    cors_rules = optional(list(object({
      # CORS configuration rules
      allowed_headers = optional(list(string), [])       # Allowed headers
      allowed_methods = list(string)                      # Allowed HTTP methods
      allowed_origins = list(string)                      # Allowed origins
      expose_headers = optional(list(string), [])       # Headers to expose
    })), [])

    # Public Access Block Configuration (required)
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  }))

  validation {
    condition = alltrue([
      for k, v in var.s3_config :
      can(regex("^[a-zA-Z0-9-_]+$", k))
    ])
    error_message = "S3 configuration keys must contain only alphanumeric characters, hyphens, and underscores."
  }

  validation {
    condition = alltrue([
      for k, v in var.s3_config :
      contains(["private", "public", "restricted"], v.accessclass)
    ])
    error_message = "Access class must be one of: private, public, restricted."
  }

  validation {
    condition = alltrue([
      for k, v in var.s3_config :
      contains(["Enabled", "Suspended", "Disabled"], v.versioning)
    ])
    error_message = "Versioning must be one of: Enabled, Suspended, Disabled."
  }

  validation {
    condition = alltrue([
      for k, v in var.s3_config :
      length(v.kms_key_id) > 0
      ])
    error_message = "KMS key ID cannot be empty for any S3 bucket configuration."
  }

  validation {
    condition = alltrue([
      for k, v in var.s3_config : alltrue([
        for stmt in v.statements :
        contains(["Allow", "Deny"], stmt.effect)
      ])
    ])
    error_message = "Policy statement effect must be either 'Allow' or 'Deny'."
  }
}
variable "additional_tags" {
  description = "Additional tags to apply to all S3 resources"
  type = map(string)
  default = {}
}

# ===============================================================================
# Credicorp Tag Variables
# ===============================================================================
variable "tag_departamento_unidad" {
  description = "Departamento o unidad organizacional"
  type        = string
}

variable "tag_nombre_aplicacion" {
  description = "Nombre de la aplicación"
  type        = string
}

variable "tag_project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "tag_centro_costo" {
  description = "Centro de costo"
  type        = string
}
