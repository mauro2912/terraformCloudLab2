variable "nat_config" {
    type = list(object({
        subnet_id = string
    }))
}

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
