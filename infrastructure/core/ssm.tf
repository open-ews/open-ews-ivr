resource "aws_ssm_parameter" "application_master_key" {
  name  = "open-ews-ivr.application_master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}
