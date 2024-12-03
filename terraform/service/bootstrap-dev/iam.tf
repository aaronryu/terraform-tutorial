resource "aws_iam_policy" "bootstrap_dev_ecr_access_policy" {
  name        = "bootstrap-dev-bootstrap-ecr-access-policy"
  description = "bootstrap dev ecr access policy"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ecr:PutLifecyclePolicy",
            "ecr:GetLifecyclePolicyPreview",
            "ecr:GetDownloadUrlForLayer",
            "ecr:ListTagsForResource",
            "ecr:UploadLayerPart",
            "ecr:BatchDeleteImage",
            "ecr:ListImages",
            "ecr:DeleteLifecyclePolicy",
            "ecr:DeleteRepository",
            "ecr:PutImage",
            "ecr:UntagResource",
            "ecr:SetRepositoryPolicy",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:DescribeImages",
            "ecr:TagResource",
            "ecr:DescribeRepositories",
            "ecr:StartLifecyclePolicyPreview",
            "ecr:InitiateLayerUpload",
            "ecr:DeleteRepositoryPolicy",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetRepositoryPolicy",
            "ecr:GetLifecyclePolicy",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_ecr_repository.bootstrap_app.arn}"
          ]
          Sid = "VisualEditor0"
        },
        {
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
          ]
          Effect   = "Allow"
          Resource = "*"
          Sid      = "VisualEditor1"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "bootstrap_dev_log_group_policy" {
  name = "bootstrap-dev-log-group-policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:log-group:/ecs/bootstrap-api-dev-taskdef:*"
          // "awslogs-group" : "/ecs/bootstrap-api-dev-taskdef", 하드코딩 or 변수
        }
      ]
    }
  )
}

resource "aws_iam_policy" "bootstrap_dev_secret_manager_access_policy" {
  name = "bootstrap-dev-secret-manager-access-policy"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Effect = "Allow"
          Resource = [
            "${aws_secretsmanager_secret.helloworld_api_dev.arn}"
          ]
          Sid = "VisualEditor0"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_user" "bootstrap_dev_ci_cd_user" {
  name = "bootstrap-dev-build-user"
  tags = {
    Role      = "bootstrap"
    Type      = "service"
    Profile   = "dev"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_policy_attachment" "bootstrap_dev_ecr_access_policy_attach" {
  name       = "bootstrap-dev-ecr-access-policy-attach"
  users      = ["${aws_iam_user.bootstrap_dev_ci_cd_user.name}"]
  roles      = []
  policy_arn = aws_iam_policy.bootstrap_dev_ecr_access_policy.arn
}


resource "aws_iam_role" "bootstrap_dev_ecs_task_execution_role" {
  name        = "bootstrap-dev-ecs-task-execution-role"
  description = "bootstrap-dev-ecs-task-execution-role"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )

  tags = {
    Profile   = "dev"
    Role      = "bootstrap"
    Type      = "iam"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_policy_attachment" "aws_managed_bootstrap_dev_ecs_task_execution_role_policy_attach" {
  name  = "aws-managed-ecs-task-bootstrap-dev-role-execution-policy-attach"
  users = []
  roles = [
    aws_iam_role.bootstrap_dev_ecs_task_execution_role.name
  ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy_attachment" "aws_log_group_bootstrap_dev_ecs_task_execution_role_policy_attach" {
  name  = "aws-log-group-ecs-task-bootstrap-dev-role-execution-policy-attach"
  users = []
  roles = [
    aws_iam_role.bootstrap_dev_ecs_task_execution_role.name
  ]
  policy_arn = aws_iam_policy.bootstrap_dev_log_group_policy.arn
}

resource "aws_iam_policy_attachment" "secret_manager_bootstrap_dev_ecs_task_execution_role_policy_attach" {
  name  = "secret-manager-task-bootstrap-dev-role-execution-policy-attach"
  users = []
  roles = [
    aws_iam_role.bootstrap_dev_ecs_task_execution_role.name
  ]
  policy_arn = aws_iam_policy.bootstrap_dev_secret_manager_access_policy.arn
}

resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}
