resource "aws_ssm_parameter" "application_master_key" {
  name  = "open-ews-ivr-registration.application_master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}
