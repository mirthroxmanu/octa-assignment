resource "aws_acm_certificate" "this" {
  domain_name               = var.acm_domain_name
  subject_alternative_names = var.another_names
  validation_method         = "DNS"

  tags = merge(tomap({ "Name" = "${var.name_prefix}-${var.name}" }), tomap({ "Launch_Month_Year" = formatdate("MMM-YYYY", timestamp()) }), tomap(var.tags))

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags
      tags, tags_all,
    ]
  }
}
