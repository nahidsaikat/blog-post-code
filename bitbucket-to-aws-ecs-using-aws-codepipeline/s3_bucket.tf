resource "aws_s3_bucket" "artifact_store" {
  bucket        = "${local.project_name}-artifacts"
  force_destroy = true
}
