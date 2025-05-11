locals {
    region                   = "eu-central-1"
    account                  = "123456789012"
    connection_id            = "90129012-9012-9012-9012-9012d8839012"
    project_name             = "demo-pipeline"
    bitbucket_connection_arn = "arn:aws:codestar-connections:${local.region}:${local.account}:connection/${local.connection_id}"
    bitbucket_repository_id  = "workspace/repository-name"
    branch_name              = "main"
    image_uri                = "${local.account}.dkr.ecr.${local.region}.amazonaws.com/${local.project_name}:latest"
    vpc_id                   = "vpc-0xxxx123465abcdef"
    subnets                  = ["subnet-1111a22222222eb99", "subnet-1111a22222222eb88"]
}
