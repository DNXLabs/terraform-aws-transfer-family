data "aws_s3_bucket" "landing" {
  bucket = var.s3_bucket_name
}