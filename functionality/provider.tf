terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "personal-labs-amsg"
    workspaces {
      prefix = "terraformCloudLab2-"
    }
  }

  required_version = "1.13.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
