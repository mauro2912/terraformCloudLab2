variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment (dev, qa)"
  type        = string
}

variable "client" {
  description = "Client name"
  type        = string
}

variable "functionality" {
  description = "Functionality name"
  type        = string
}

variable "ticket" {
  description = "Ticket ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets configuration"
  type = list(object({
    ticket            = string
    cidr_block        = string
    availability_zone = string
    service           = string
    accessclass       = string
  }))
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}
