resource "aws_iam_role" "job_completion_lambda_role" {
  name               = "job-completion-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "job_completion_lambda_role_logs" {
  role   = aws_iam_role.job_completion_lambda_role.name
  policy = data.aws_iam_policy_document.lambda_policies.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_policies" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../lambdas/mediaconvert_job_completion_lambda"
  output_path = "completion_handler.zip"
}


resource "aws_lambda_function" "mediaconvert_completion_lambda" {
  function_name    = "mediaconverter-completion-lambda"
  filename         = "completion_handler.zip"
  handler          = "handler.lambda_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.job_completion_lambda_role.arn
  memory_size      = "128"
  timeout          = "10"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  environment {
    variables = {
      DEFAULT_AWS_REGION = var.region
      OUTPUT_BUCKET      = aws_s3_bucket.output_bucket.id
      ENV                = var.env
    }
  }
}

resource "aws_lambda_permission" "eventbridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mediaconvert_completion_lambda.function_name
  source_arn    = aws_cloudwatch_event_rule.job_completion.arn
  principal     = "events.amazonaws.com"
}
