variable "client" {
  type = string
}

variable "functionality" {
  type = string
}

variable "environment" {
  type = string
}

variable "ticket" {
  type = string
}

variable "vpc_id" {
  type = string
}

# Terraform doesnt consider boolean variables as number,
# for that reason we use number to validate with count
variable "create_igw" {
  type = number
}