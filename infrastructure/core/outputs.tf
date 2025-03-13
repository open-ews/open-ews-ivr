output "ecr_repository" {
  value = module.ecr_repository
}

output "application_master_key" {
  value     = aws_ssm_parameter.application_master_key
  sensitive = true
}
