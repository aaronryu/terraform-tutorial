resource "aws_ecr_repository" "bootstrap_app" {
    name = "bootstrap-app"

    tags = {
      Role      = "bootstrap"
      Profile   = "dev"
      Name      = "bootstrap_app"
      ManagedBy = "terraform"
    }
}
