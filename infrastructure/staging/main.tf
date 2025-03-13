module "app" {
  source = "../modules/app"

  identifier             = "open-ews-ivr-staging"
  app_environment        = "staging"
  subdomain              = "ivr-staging"
  app_image              = data.terraform_remote_state.core.outputs.ecr_repository.this.repository_url
  application_master_key = data.terraform_remote_state.core.outputs.application_master_key
  public_route53_zone    = data.terraform_remote_state.open_ews_core_infrastructure.outputs.route53_zone
  internal_route53_zone  = data.terraform_remote_state.open_ews_core_infrastructure.outputs.internal_route53_zone
  region                 = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
}
