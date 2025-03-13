terraform {
  backend "s3" {
    bucket  = "infrastructure.open-ews.org"
    key     = "bootstrap.tfstate"
    encrypt = true
    region  = "ap-southeast-1"
  }
}
