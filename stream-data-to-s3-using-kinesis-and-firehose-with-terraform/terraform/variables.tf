variable "kinesis_stream_name" {
  description = "Kinesis Data Stream Name"
  default     = "demo-event-log-stream"
}

variable "iam_name_prefix" {
  description = "Prefix used for all created IAM roles and policies"
  type        = string
  nullable    = false
  default     = "demo-kinesis-firehose-"
}
