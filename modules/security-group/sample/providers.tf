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
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "transer"
      Owner       = "cloudops"
      ManagedBy   = "terraform"
      Module      = "security-group-sample"
    }
  }
}
