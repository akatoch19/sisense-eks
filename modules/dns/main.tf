resource "aws_route53_zone" "this" {
  name = "${var.env}.sisense.example.com"
}
