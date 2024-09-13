# S3 Bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket_prefix = var.name

  tags = {
    Name = var.tag
  }
}