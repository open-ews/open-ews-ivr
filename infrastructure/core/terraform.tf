terraform {
  backend "s3" {
    bucket  = "infrastructure.open-ews.org"
    key     = "open-ews-ivr-registration.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_region
}
