resource "aws_ecs_cluster" "martailer_api_worker" {
  name = local.project_name
}

resource "aws_cloudwatch_log_group" "martailer_api_worker" {
  name = "/ecs/${local.project_name}"
}

resource "aws_ecs_service" "martailer_api_worker" {
  name            = local.project_name
  cluster         = aws_ecs_cluster.martailer_api_worker.id
  task_definition = aws_ecs_task_definition.martailer_api_worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = local.subnets
    security_groups = [aws_security_group.martailer_api_worker.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "martailer_api_worker" {
  name        = local.project_name
  description = "Allow inbound traffic to martailer worker"
  vpc_id      = local.vpc_id
  ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_iam_role" "task_definition_role" {
  name = "${local.project_name}-task-definition-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "task_definition_policy" {
  name = "${local.project_name}-task-definition-role-policy"
  role = aws_iam_role.task_definition_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameters"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "martailer_api_worker" {
  family                   = local.project_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = <<DEFINITION
[
  {
    "name": "${local.project_name}",
    "image": "${aws_ecr_repository.app.repository_url}:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.martailer_api_worker.name}",
        "awslogs-region": "${local.region}",
        "awslogs-stream-prefix": "${local.project_name}"
      }
    }
  }
]
DEFINITION
  execution_role_arn = aws_iam_role.task_definition_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
