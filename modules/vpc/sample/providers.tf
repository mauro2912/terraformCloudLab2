terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.31.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      environment = var.environment
      project     = var.functionality
      owner       = "cloudops"
      client      = var.client
      area        = "infrastructure"
      provisioned = "terraform"
      datatype    = "operational"
      example     = "vpc-module-sample"
    }
  }
}
