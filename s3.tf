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

resource "aws_s3_bucket_public_access_block" "sftp" {
  bucket = aws_s3_bucket.sftp.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "sftp" {
  bucket = aws_s3_bucket.sftp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.sftp.arn,
          "${aws_s3_bucket.sftp.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.sftp]
}
