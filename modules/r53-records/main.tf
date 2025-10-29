#data "aws_route53_zone" "selected" {
#  name         = var.hosted_zone_domain
#  private_zone = var.is_private
#  
#}

resource "aws_route53_record" "this" {
  zone_id = var.record_zone_id #data.aws_route53_zone.selected.zone_id
  name    = var.record_domain_name
  type    = var.record_type
  ttl     = var.record_ttl
  records = var.record_value
}
