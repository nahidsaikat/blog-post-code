resource "aws_cloudwatch_log_group" "demo_firebose_log_group" {
  name = "/aws/kinesisfirehose/${var.kinesis_stream_name}-delivery"

  tags = {
    Product = "Demo"
  }
}

resource "aws_cloudwatch_log_stream" "demo_firebose_log_stream" {
  name           = "/aws/kinesisfirehose/${var.kinesis_stream_name}-stream"
  log_group_name = aws_cloudwatch_log_group.demo_firebose_log_group.name
}
