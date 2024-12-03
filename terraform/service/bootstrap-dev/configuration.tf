terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "bootstrap-terraform-state-storage"
    key            = "service/bootstrap-dev/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    kms_key_id     = "alias/bootstrap-tfstate-enc-key"
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}
