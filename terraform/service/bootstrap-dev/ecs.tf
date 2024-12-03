resource "aws_ecs_cluster" "bootstrap_dev_ecs_cluster" {
  name = "bootstrap-dev-ecs-cluster"

  tags = {
    Profile   = "dev"
    Role      = "bootstrap"
    Type      = "ecs"
    ManagedBy = "terraform"
  }
}

resource "aws_ecs_service" "bootstrap_api_dev_ecs_service" {
  name          = "bootstrap-api-dev-ecs-service"
  cluster       = aws_ecs_cluster.bootstrap_dev_ecs_cluster.id
  desired_count = 2

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_ecs_managed_tags           = false
  health_check_grace_period_seconds = 60

  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.bootstrap_api_dev_taskdef.family

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = "app" # nginx
    container_port   = 3000  # 80
    target_group_arn = aws_lb_target_group.bootstrap_api_alb_tg_dev.arn
  }

  network_configuration {
    security_groups = [
      data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_private_sg_id
    ]
    subnets = [
      data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_private_subnet_0_id,
      data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_private_subnet_1_id
    ]
    assign_public_ip = false
  }

  depends_on = [
    aws_lb_listener.bootstrap_api_alb_tg_dev_http,
    aws_iam_policy_attachment.aws_managed_bootstrap_dev_ecs_task_execution_role_policy_attach
  ]

  tags = {
    Profile   = "dev"
    Role      = "bootstrap"
    Type      = "ecs"
    ManagedBy = "terraform"
  }
}

resource "aws_ecs_task_definition" "bootstrap_api_dev_taskdef" {
  family                   = "bootstrap-api-dev-taskdef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode(
    [
      {
        environment = [
          {
            name  = "AWS_PROFILE"
            value = "bootstrap-api-dev"
          },
          {
            name  = "AWS_REGION"
            value = "ap-northeast-2"
          },
          {
            name  = "DB_USER"
            value = "bootstrap_dev"
          },
          {
            name  = "INSTANCE_ENV"
            value = "development"
          },
        ]
        secrets = [
          {
            name      = "NEXTAUTH_URL"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:NEXTAUTH_URL::"
          },
          {
            name      = "NEXTAUTH_URL_INTERNAL"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:NEXTAUTH_URL_INTERNAL::"
          },
          {
            name      = "NEXT_PUBLIC_FRONT_HOST"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:NEXT_PUBLIC_FRONT_HOST::"
          },
          {
            name      = "NEXT_PUBLIC_API_HOST"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:NEXT_PUBLIC_API_HOST::"
          },
          {
            name      = "NEXT_PUBLIC_CDN_HOST"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:NEXT_PUBLIC_CDN_HOST::"
          },
          {
            name      = "NEXTAUTH_SECRET"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:NEXTAUTH_SECRET::"
          },
          {
            name      = "GOOGLE_OAUTH_ID"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:GOOGLE_OAUTH_ID::"
          },
          {
            name      = "GOOGLE_OAUTH_SECRET"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:GOOGLE_OAUTH_SECRET::"
          },
          {
            name      = "GITHUB_OAUTH_ID"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:GITHUB_OAUTH_ID::"
          },
          {
            name      = "GITHUB_OAUTH_SECRET"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:GITHUB_OAUTH_SECRET::"
          },
          {
            name      = "DATABASE_URL"
            valueFrom = "${aws_secretsmanager_secret.bootstrap_api_dev.arn}:DATABASE_URL::"
          },
        ]
        essential         = true
        image             = "${aws_ecr_repository.bootstrap_app.repository_url}:dev-latest"
        memoryReservation = 500
        mountPoints       = []
        name              = "app"
        portMappings = [
          {
            # hostPort = 3000,
            containerPort = 3000
          }
        ]
        volumesFrom = []
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-create-group" : "true",
            "awslogs-group" : "/ecs/bootstrap-api-dev-taskdef",
            "awslogs-region" : "ap-northeast-2",
            "awslogs-stream-prefix" : "ecs"
          }
        }
      }
    ]
  )

  execution_role_arn = aws_iam_role.bootstrap_dev_ecs_task_execution_role.arn

  task_role_arn = aws_iam_role.bootstrap_dev_ecs_task_execution_role.arn

  tags = {
    Profile   = "dev"
    Role      = "bootstrap"
    Type      = "ecs_taskdef"
    ManagedBy = "terraform"
  }
}
