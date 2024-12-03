data "terraform_remote_state" "vpc_dev" {
  backend = "s3"
  config = {
    bucket         = "bootstrap-terraform-state-storage"
    key            = "common/vpc-dev/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    kms_key_id     = "alias/bootstrap-tfstate-enc-key"
  }
}
