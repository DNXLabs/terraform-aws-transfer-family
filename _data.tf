data "aws_s3_bucket" "landing" {
  bucket = aws_s3_bucket.sftp.id
}