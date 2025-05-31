resource "aws_s3_bucket" "input_bucket" {
  bucket        = "mediaconvert-input"
  force_destroy = true
}

resource "aws_s3_bucket" "output_bucket" {
  bucket        = "mediaconvert-output"
  force_destroy = true
}
