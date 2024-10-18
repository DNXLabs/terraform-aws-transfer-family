data "aws_route53_zone" "selected" {
  name = var.domain_zone
}

resource "aws_route53_record" "transfer-family" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_host
  type    = "CNAME"
  ttl     = "300"
  records = [aws_transfer_server.default.endpoint]
}