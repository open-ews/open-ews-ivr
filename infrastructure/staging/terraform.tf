terraform {
  backend "s3" {
    bucket  = "infrastructure.open-ews.org"
    key     = "open-ews-ivr-staging.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_default_region
}

data "aws_ecr_authorization_token" "this" {}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.this.proxy_endpoint
    username = data.aws_ecr_authorization_token.this.user_name
    password = data.aws_ecr_authorization_token.this.password
  }
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "infrastructure.open-ews.org"
    key    = "open-ews-ivr.tfstate"
    region = var.aws_default_region
  }
}

data "terraform_remote_state" "open_ews_core_infrastructure" {
  backend = "s3"

  config = {
    bucket = "infrastructure.open-ews.org"
    key    = "open-ews-core.tfstate"
    region = var.aws_default_region
  }
}

data "terraform_remote_state" "core_infrastructure" {
  backend = "s3"

  config = {
    bucket = "infrastructure.somleng.org"
    key    = "core.tfstate"
    region = var.aws_default_region
  }
}
