resource "aws_lb" "bootstrap_api_alb_dev" {
  name     = "bootstrap-api-alb-dev"
  internal = false
  subnets = [
    data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_public_subnet_0_id,
    data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_public_subnet_1_id
  ]
  load_balancer_type = "application"
  security_groups = [
    data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_default_sg_id,
    data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_specific_ips_sg_id
  ]

  tags = {
    Profile   = "dev"
    Role      = "bootstrap"
    Type      = "alb"
    ManagedBy = "terraform"
  }
}

resource "aws_lb_target_group" "bootstrap_api_alb_tg_dev" {
  name        = "bootstrap-api-alb-tg-dev"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc_dev.outputs.bootstrap_dev_vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/api/hello"
    timeout             = 60
    matcher             = "200"
    port                = "3000"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "bootstrap_api_alb_tg_dev_https" {
  load_balancer_arn = aws_lb.bootstrap_api_alb_dev.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bootstrap_api_alb_tg_dev.arn
  }
}

# resource "aws_lb_listener" "bootstrap_api_alb_tg_dev_http" {
#   load_balancer_arn = aws_lb.bootstrap_api_alb_dev.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"
#     # type             = "forward"
#     # target_group_arn = aws_lb_target_group.bootstrap_api_alb_tg_dev.arn
#   }
# }

# RedirectConfig
