locals {
  common_tags = {
    client        = "amsg"
    functionality = "tfcloud-lab"
    managed_by    = "Terraform"
    owner         = "andres.gonzalez@pragma.com.co"
    environment   = var.environment
  }
}
