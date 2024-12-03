resource "aws_secretsmanager_secret" "helloworld_api_dev" {
  force_overwrite_replica_secret = false
  name                           = "bootstrap-api/dev/v1"
  tags                           = {}
  tags_all                       = {}
}
