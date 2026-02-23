output "s3_bucket_info" {
  description = "Map containing S3 bucket information including ARN, ID, domain name and metadata for each key"
  value = {
    for key, bucket in aws_s3_bucket.main : key => {
      "bucket_arn"         = bucket.arn
      "bucket_id"          = bucket.id
      "bucket_domain_name" = bucket.bucket_regional_domain_name
      "bucket_name"        = bucket.tags_all.Name
      "application"        = try(bucket.tags_all.application, "")
      "accessclass"        = bucket.tags_all.accessclass
    }
  }
}

output "bucket_arns" {
  description = "Map of S3 bucket ARNs organized by configuration key"
  value       = { for k, v in aws_s3_bucket.main : k => v.arn }
}

output "bucket_ids" {
  description = "Map of S3 bucket IDs organized by configuration key"
  value       = { for k, v in aws_s3_bucket.main : k => v.id }
}

output "bucket_domain_names" {
  description = "Map of S3 bucket regional domain names organized by configuration key"
  value       = { for k, v in aws_s3_bucket.main : k => v.bucket_regional_domain_name }
}

output "bucket_names" {
  description = "Map of S3 bucket names organized by configuration key"
  value       = { for k, v in aws_s3_bucket.main : k => v.tags_all.Name }
}

output "s3_info_list" {
  description = "List of S3 bucket information for compatibility with existing implementations"
  value = [
    for key, bucket in aws_s3_bucket.main : {
      "s3_arn"         = bucket.arn
      "s3_id"          = bucket.id
      "s3_domain_name" = bucket.bucket_regional_domain_name
      "s3_name"        = bucket.tags_all.Name
    }
  ]
}

output "s3_info_map" {
  description = "Map of S3 bucket information organized by bucket name for compatibility"
  value = {
    for key, bucket in aws_s3_bucket.main : bucket.tags_all.Name => {
      "s3_arn"         = bucket.arn
      "s3_id"          = bucket.id
      "s3_domain_name" = bucket.bucket_regional_domain_name
      "s3_name"        = bucket.tags_all.Name
    }
  }
}

output "encryption_configurations" {
  description = "Map of S3 bucket encryption configuration IDs organized by configuration key"
  value       = { for k, v in aws_s3_bucket_server_side_encryption_configuration.encryption_bucket : k => v.id }
}

output "versioning_configurations" {
  description = "Map of S3 bucket versioning configuration IDs organized by configuration key"
  value       = { for k, v in aws_s3_bucket_versioning.s3_general_versioning : k => v.id }
}

output "bucket_policies" {
  description = "Map of S3 bucket policy IDs for buckets with policies, organized by configuration key"
  value       = { for k, v in aws_s3_bucket_policy.policy : k => v.id }
}

output "cors_configurations" {
  description = "Map of S3 bucket CORS configuration IDs for buckets with CORS, organized by configuration key"
  value       = { for k, v in aws_s3_bucket_cors_configuration.cors : k => v.id }
}
