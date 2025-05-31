resource "aws_iam_role" "lambda_execution_role" {
  name = "mediaconvert-trigger-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "mediaconvert-trigger-lambda-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

resource "aws_iam_role_policy" "task_definition_policy" {
  name   = "mediaconvert-trigger-lambda-role-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "Logging"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::${var.account_id}:role/service-role/MediaConvert_Default_Role"
            ],
            "Effect": "Allow",
            "Sid": "PassRole"
        },
        {
            "Action": [
                "mediaconvert:*"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow",
            "Sid": "MediaConvertService"
        }
    ]
  }
EOF
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_dir  = "../lambdas/mediaconvert_job_trigger_lambda"
  output_path = "trigger_handler.zip"
}

resource "aws_lambda_function" "video_converter_lambda" {
  function_name    = "mediaconverter-trigger-lambda"
  filename         = "trigger_handler.zip"
  handler          = "handler.lambda_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_execution_role.arn
  memory_size      = "128"
  timeout          = "10"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  environment {
    variables = {
      DEFAULT_AWS_REGION     = var.region
      OUTPUT_BUCKET          = aws_s3_bucket.output_bucket.id
      ENV                    = var.env
      MEDIA_CONVERT_ROLE_ARN = "arn:aws:iam::${var.account_id}:role/service-role/MediaConvert_Default_Role"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_converter_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.input_bucket.bucket}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.video_converter_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "banners/"
    filter_suffix       = ".mp4"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
