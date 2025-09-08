resource "aws_route53_zone" "this" {
  name = var.zone_name
}

output "zone_id" {
  value = aws_route53_zone.this.zone_id
}
