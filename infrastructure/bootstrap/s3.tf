module "aws-s3-bucket" {
  source                   = "trussworks/s3-private-bucket/aws"
  bucket                   = "infrastructure.open-ews.org"
  use_account_alias_prefix = false
}
