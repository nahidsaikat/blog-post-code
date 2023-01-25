resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-bucket"

  tags = {
    Environment = "demo"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.demo_bucket.id
  acl    = "private"
}
