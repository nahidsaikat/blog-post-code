variable "account_number" {}

variable "s3_bucket_name" {
  default = "cloudfront-demo-bucket"
}

locals {
  s3_origin_id = "demoS3Origin"
}

data "aws_cloudfront_cache_policy" "cache_policy" {
    name = "Managed-CachingOptimized"
}

output "cf_domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}
