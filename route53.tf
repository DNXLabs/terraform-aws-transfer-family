data "aws_route53_zone" "selected" {
  count = var.domain_zone != "" ? 1 : 0
  name = var.domain_zone
}

resource "aws_route53_record" "transfer-family" {
  count = var.domain_zone != "" && var.domain_host != "" ? 1 : 0
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.domain_host
  type    = "CNAME"
  ttl     = "300"
  records = [aws_transfer_server.default.endpoint]
}