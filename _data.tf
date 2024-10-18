data "aws_s3_bucket" "landing" {
  bucket = aws_s3_bucket.sftp.id
}


data "aws_region" "current" {}
data "aws_caller_identity" "current" {}