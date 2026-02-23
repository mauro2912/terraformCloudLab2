###########################################
#Common variables
###########################################
variable "client" {
  type = string
}

variable "functionality" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cidr_blocks" {
  type = list(object({
    ticket = string
    cidr_block = string
    availability_zone = string
    service = string
    accessclass = string
  }))
  /* validation {
      condition = can([for s in var.cidr_blocks : regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", s)])
      error_message = "Each item of the 'private_subnets' List must be in a CIDR block format. Example: [\"10.106.108.0/25\"]."
  } */
}

variable "gateway_id" {
  type = list(string)
  default = []
}

variable "nat_id" {
  type = list(string)
  default = []
}

