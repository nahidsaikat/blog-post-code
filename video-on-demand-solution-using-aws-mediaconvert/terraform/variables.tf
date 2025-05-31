variable "account_id" {
  description = "The AWS account ID where the MediaConvert job will be created."
}

variable "region" {
  description = "The AWS region where the MediaConvert job will be created."
  default = "us-east-1"
}

variable "env" {
  description = "The environment for the MediaConvert job."
}
