#resource "aws_route53_zone" "this" {
  #name = var.zone_name
 # comment = "Sisense DNS Zone for ${var.env}"
 # tags = var.tags
#}

#output "zone_id" { value = aws_route53_zone.this.zone_id }

resource "aws_route53_zone" "private_zone" {
name = var.zone_name # replace with your hosted zone name
vpc {
vpc_id = module.vpc.vpc_id
}
comment = "Private zone for Sisense staging"
force_destroy = false
}


resource "aws_route53_record" "app_api" {
zone_id = aws_route53_zone.private_zone.zone_id
name = "api.centralsquare-stage.com"
type = "A"


alias {
name = aws_lb.my_lb.dns_name # replace with your LB resource
zone_id = aws_lb.my_lb.zone_id
evaluate_target_health = true
}
}
