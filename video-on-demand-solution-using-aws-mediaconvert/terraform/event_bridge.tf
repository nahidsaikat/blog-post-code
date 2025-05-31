data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

resource "aws_cloudwatch_event_rule" "job_completion" {
  name           = "mediaconvert-job-completion-rule"
  description    = "Rule to trigger when a MediaConvert job is completed"
  event_bus_name = data.aws_cloudwatch_event_bus.default.name


  event_pattern = <<EOF
      {
        "source": ["aws.mediaconvert"],
        "detail-type": ["MediaConvert Job State Change"],
        "detail": {
            "status": ["COMPLETE", "ERROR"],
            "userMetadata": {
                "env": [
                    "${var.env}"
                ]
            }
        }
      }
    EOF
}

resource "aws_cloudwatch_event_target" "target" {
  arn  = aws_lambda_function.mediaconvert_completion_lambda.arn
  rule = aws_cloudwatch_event_rule.job_completion.name
}
