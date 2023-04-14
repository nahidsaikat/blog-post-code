resource "aws_kinesis_firehose_delivery_stream" "demo_delivery_stream" {
  name        = "${var.kinesis_stream_name}-delivery"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.demo_bucket.arn

    buffer_size = 5
    buffer_interval = 60

    cloudwatch_logging_options {
      enabled = "true"
      log_group_name = aws_cloudwatch_log_group.demo_firebose_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.demo_firebose_log_stream.name
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn  = aws_kinesis_stream.demo_stream.arn
    role_arn            = aws_iam_role.firehose.arn
  }

  tags = {
    Product = "Demo"
  }
}
