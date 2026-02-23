# =============================================
# Environment Configuration - DEV
# =============================================

aws_region  = "us-east-1"
environment = "dev"
client      = "lab"
functionality = "tfcloud-lab"
ticket      = "LAB-001"

# =============================================
# VPC Configuration
# =============================================
vpc_cidr_block = "10.0.0.0/16"

public_subnets = [
  {
    ticket            = "LAB-001"
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    service           = "public"
    accessclass       = "public"
  },
  {
    ticket            = "LAB-001"
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    service           = "public"
    accessclass       = "public"
  }
]

# =============================================
# S3 Configuration
# =============================================
s3_bucket_name = "lab-tfcloud-dev-data"
