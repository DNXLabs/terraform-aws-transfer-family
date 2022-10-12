resource "aws_s3_bucket" "sftp" {
  bucket_prefix   = var.s3_bucket_name
  versioning {
    enabled       = try(var.s3_bucket_versioning, true)
  }
}