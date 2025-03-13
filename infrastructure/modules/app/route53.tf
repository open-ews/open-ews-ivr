

resource "aws_route53_record" "public" {
  count = var.public_route53_zone != null ? 1 : 0

  zone_id = var.public_route53_zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.region.public_load_balancer.this.dns_name
    zone_id                = var.region.public_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "internal" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.region.internal_load_balancer.this.dns_name
    zone_id                = var.region.internal_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}
