variable "identifier" {}
variable "app_environment" {}
variable "app_image" {}
variable "region" {}
variable "subdomain" {}
variable "application_master_key" {}
variable "internal_route53_zone" {}
variable "audio_bucket" {}
variable "public_route53_zone" {
  default = null
}
