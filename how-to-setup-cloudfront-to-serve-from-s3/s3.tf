resource "aws_s3_bucket" "b" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  bucket = aws_s3_bucket.b.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "b_acl" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_access_from_cloud_front" {
  bucket = aws_s3_bucket.b.id
  policy = <<POLICY
  {
      "Version": "2008-10-17",
      "Id": "PolicyForCloudFrontPrivateContent",
      "Statement": [
          {
              "Sid": "AllowCloudFrontServicePrincipal",
              "Effect": "Allow",
              "Principal": {
                  "Service": "cloudfront.amazonaws.com"
              },
              "Action": "s3:GetObject",
              "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
              "Condition": {
                  "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::666546513550:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
                  }
              }
          }
      ]
  }
  POLICY
}
