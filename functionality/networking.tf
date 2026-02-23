# =============================================
# VPC Module
# =============================================
module "vpc" {
  source = "../modules/vpc"

  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  service       = "network"
  ticket        = var.ticket

  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  public_cidr_blocks  = var.public_subnets
  private_cidr_blocks = []
  rds_cidr_blocks     = []

  create_igw = 1
  nat_config = []

  additional_tags = local.common_tags
}
