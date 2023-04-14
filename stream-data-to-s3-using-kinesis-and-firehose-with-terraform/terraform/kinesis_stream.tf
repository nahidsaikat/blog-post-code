resource "aws_kinesis_stream" "demo_stream" {
  name             = "${var.kinesis_stream_name}"
  retention_period = 24

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Product = "Demo"
  }
}
