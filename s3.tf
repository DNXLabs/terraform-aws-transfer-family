resource "aws_s3_bucket" "sftp" {
  bucket_prefix = var.s3_bucket_name
  versioning {
    enabled = try(var.s3_bucket_versioning, true)
  }
  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
