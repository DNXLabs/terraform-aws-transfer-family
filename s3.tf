resource "aws_s3_bucket" "sftp" {
  bucket_prefix = var.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "sftp" {
  bucket = aws_s3_bucket.sftp.id
  versioning_configuration {
    status = try(var.s3_bucket_versioning, "Enabled")
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sftp" {
  bucket = aws_s3_bucket.sftp.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
