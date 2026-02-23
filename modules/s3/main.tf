# S3 Bucket Resource
resource "aws_s3_bucket" "main" {
  for_each = var.s3_config
  
  bucket = "${var.client}-${var.project}-${var.environment}-s3-${each.key}"
  
  tags = merge(
    {
      Name                   = "${var.client}-${var.project}-${var.environment}-s3-${each.key}"
      accessclass           = each.value.accessclass
      Tag_DepartamentoUnidad = var.tag_departamento_unidad
      Tag_NombreAplicacion   = var.tag_nombre_aplicacion
      Tag_ProjectName        = var.tag_project_name
      Tag_CentroCosto        = var.tag_centro_costo
      Environment            = var.environment
    },
    each.value.additional_tags
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# S3 Bucket Server Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_bucket" {
  for_each = var.s3_config
  
  bucket = aws_s3_bucket.main[each.key].id

  rule {
    bucket_key_enabled = each.value.kms_key_id == "AES256" ? null : false
    apply_server_side_encryption_by_default {
      # Support both AES256 and KMS encryption
      sse_algorithm     = each.value.kms_key_id == "AES256" ? "AES256" : "aws:kms"
      kms_master_key_id = each.value.kms_key_id == "AES256" ? null : each.value.kms_key_id
    }
  }
  
  depends_on = [aws_s3_bucket.main]
}

# S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "general_ownership" {
  for_each = var.s3_config
  
  bucket = aws_s3_bucket.main[each.key].id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  
  depends_on = [aws_s3_bucket.main]
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "general_public_access" {
  for_each = var.s3_config
  
  bucket                  = aws_s3_bucket.main[each.key].id
  block_public_acls       = try(each.value.block_public_acls, true)
  block_public_policy     = try(each.value.block_public_policy, true)
  ignore_public_acls      = try(each.value.ignore_public_acls, true)
  restrict_public_buckets = try(each.value.restrict_public_buckets, true)
  
  depends_on = [aws_s3_bucket.main]
}

# S3 Bucket Versioning Configuration
resource "aws_s3_bucket_versioning" "s3_general_versioning" {
  for_each = var.s3_config
  
  bucket = aws_s3_bucket.main[each.key].id
  
  versioning_configuration {
    status = each.value.versioning
  }
  
  depends_on = [aws_s3_bucket.main]
}

# Dynamic IAM Policy Document for S3 Bucket Policies
data "aws_iam_policy_document" "dynamic_policy" {
  for_each = {
    for k, v in var.s3_config : k => v
    if length(v.statements) > 0
  }
  
  dynamic "statement" {
    for_each = each.value.statements
    content {
      sid       = statement.value.sid
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = statement.value.effect
      
      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }

      dynamic "condition" {
        for_each = statement.value.condition
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "policy" {
  for_each = {
    for k, v in var.s3_config : k => v
    if length(v.statements) > 0
  }
  
  bucket = aws_s3_bucket.main[each.key].id
  policy = data.aws_iam_policy_document.dynamic_policy[each.key].json
  
  depends_on = [aws_s3_bucket.main]
}

# Lambda Permission for S3 Notifications
resource "aws_lambda_permission" "s3_lambda_permission" {
  for_each = {
    for item in flatten([
      for bucket_key, bucket_config in var.s3_config : [
        for notification_idx, notification in bucket_config.lambda_notifications : {
          key                  = "${bucket_key}-notification-${notification_idx}"
          bucket_key          = bucket_key
          lambda_function_arn = notification.lambda_function_arn
        }
      ]
    ]) : item.key => item
  }
  
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.main[each.value.bucket_key].arn
  
  depends_on = [aws_s3_bucket.main]
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = {
    for k, v in var.s3_config : k => v
    if length(v.lambda_notifications) > 0
  }
  
  bucket = aws_s3_bucket.main[each.key].id

  dynamic "lambda_function" {
    for_each = each.value.lambda_notifications
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  depends_on = [
    aws_s3_bucket.main,
    aws_lambda_permission.s3_lambda_permission
  ]
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "cors" {
  for_each = {
    for k, v in var.s3_config : k => v
    if length(v.cors_rules) > 0
  }
  
  bucket = aws_s3_bucket.main[each.key].id

  dynamic "cors_rule" {
    for_each = each.value.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
    }
  }
  
  depends_on = [aws_s3_bucket.main]
}