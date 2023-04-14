resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.kinesis_stream_name}-data"

  tags = {
    Product = "Martailer"
  }
}

resource "aws_s3_bucket_acl" "demo_bucket_acl" {
  bucket = aws_s3_bucket.demo_bucket.id
  acl    = "private"
}
