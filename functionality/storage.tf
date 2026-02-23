# =============================================
# S3 Module
# =============================================
module "s3" {
  source = "../modules/s3"

  client      = var.client
  project     = var.functionality
  environment = var.environment
  application = "data"

  tag_departamento_unidad = "Labs"
  tag_nombre_aplicacion   = "TerraformCloud Lab"
  tag_project_name        = "LAB-001"
  tag_centro_costo        = "N/A"

  s3_config = {
    main = {
      kms_key_id              = "alias/aws/s3"
      accessclass             = "private"
      versioning              = "Enabled"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }
}
