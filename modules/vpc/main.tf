
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    {
      Name          = "${var.client}-${var.functionality}-${var.environment}-vpc"
      client        = var.client
      functionality = var.functionality
      environment   = var.environment
      service       = var.service
      id_case       = var.ticket
    },
    var.additional_tags
  )
}

module "public_subnets" {
  source        = "./subnet"
  vpc_id        = aws_vpc.main.id
  cidr_blocks   = var.public_cidr_blocks
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  gateway_id    = module.internet_gateway.igw_id
}

module "private_subnets" {
  source        = "./subnet"
  vpc_id        = aws_vpc.main.id
  cidr_blocks   = var.private_cidr_blocks
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  nat_id        = module.nat_gateway.nat_id
}

module "database_subnets" {
  source        = "./subnet"
  vpc_id        = aws_vpc.main.id
  cidr_blocks   = var.rds_cidr_blocks
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
}

module "internet_gateway" {
  source        = "./internet_gateway"
  vpc_id        = aws_vpc.main.id
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  ticket        = var.ticket
  create_igw    = var.create_igw
}
module "nat_gateway" {
  source        = "./nat_gateway"
  client        = var.client
  functionality = var.functionality
  environment   = var.environment
  nat_config = var.nat_config
}


