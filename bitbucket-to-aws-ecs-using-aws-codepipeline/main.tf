 terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    backend "s3" {
        bucket         = "martailer-terraform-deployments"
        key            = "martailer-dashboard-api-worker/terraform.tfstate"
        region         = "eu-central-1"
        dynamodb_table = "martailer-terraform-state"
        encrypt        = true
    }
}

provider "aws" {
    region = local.region
}
