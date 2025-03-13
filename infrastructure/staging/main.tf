module "app" {
  source = "../modules/app"

  identifier             = "open-ews-ivr-registration-staging"
  app_environment        = "staging"
  app_image              = data.terraform_remote_state.core.outputs.ecr_repository.this.repository_url
  region                 = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  application_master_key = data.terraform_remote_state.core.outputs.application_master_key
}
