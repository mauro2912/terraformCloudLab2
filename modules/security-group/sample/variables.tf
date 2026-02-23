variable "client" {
  description = "Client name identifier"
  type        = string
  default     = "transer"
}

variable "functionality" {
  description = "Functionality or specific project identifier"
  type        = string
  default     = "webapp"
}

variable "environment" {
  description = "Deployment environment (dev, qa, pdn)"
  type        = string
  default     = "dev"
  
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
  
  default = {
    # Web tier security group - public access
    "web-servers" = {
      ticket      = "TRANS-001"
      description = "Security group for web servers with public access"
      vpc_id      = "vpc-12345678"  # Replace with your VPC ID
      application = "web"
      accessclass = "public"
      ingress = [
        {
          from_port       = 80
          to_port         = 80
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          description     = "HTTP access from anywhere"
        },
        {
          from_port       = 443
          to_port         = 443
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          description     = "HTTPS access from anywhere"
        },
        {
          from_port       = 22
          to_port         = 22
          protocol        = "tcp"
          cidr_blocks     = ["10.0.0.0/8"]
          security_groups = []
          description     = "SSH access from private networks"
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
    
    # Application tier security group - private access
    "app-servers" = {
      ticket      = "TRANS-002"
      description = "Security group for application servers"
      vpc_id      = "vpc-12345678"  # Replace with your VPC ID
      application = "app"
      accessclass = "private"
      ingress = [
        {
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = []  # Will be populated with web-servers SG ID
          description     = "Application access from web tier"
        },
        {
          from_port       = 22
          to_port         = 22
          protocol        = "tcp"
          cidr_blocks     = ["10.0.0.0/8"]
          security_groups = []
          description     = "SSH access from private networks"
        }
      ]
      egress = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS outbound for API calls"
        },
        {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
          description = "PostgreSQL database access"
        }
      ]
    }
    
    # Database tier security group - restricted access
    "db-servers" = {
      ticket      = "TRANS-003"
      description = "Security group for database servers"
      vpc_id      = "vpc-12345678"  # Replace with your VPC ID
      application = "database"
      accessclass = "restricted"
      ingress = [
        {
          from_port       = 5432
          to_port         = 5432
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = []  # Will be populated with app-servers SG ID
          description     = "PostgreSQL access from application tier"
        },
        {
          from_port       = 22
          to_port         = 22
          protocol        = "tcp"
          cidr_blocks     = ["10.0.1.0/24"]
          security_groups = []
          description     = "SSH access from bastion subnet only"
        }
      ]
      egress = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS outbound for updates"
        }
      ]
    }
    
    # Load balancer security group
    "load-balancer" = {
      ticket      = "TRANS-004"
      description = "Security group for Application Load Balancer"
      vpc_id      = "vpc-12345678"  # Replace with your VPC ID
      application = "alb"
      accessclass = "public"
      ingress = [
        {
          from_port       = 80
          to_port         = 80
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          description     = "HTTP access from internet"
        },
        {
          from_port       = 443
          to_port         = 443
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          description     = "HTTPS access from internet"
        }
      ]
      egress = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
          description = "Forward to application servers"
        }
      ]
    }
  }
}
