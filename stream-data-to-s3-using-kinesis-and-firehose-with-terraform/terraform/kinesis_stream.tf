resource "aws_kinesis_stream" "demo_stream" {
  name             = "terraform-kinesis-demo"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = "demo"
  }
}
