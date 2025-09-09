#########################################################
# Outputs
#########################################################
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "fsx_dns_name" {
  value = module.storage.fsx_dns_name
}

#output "route53_zone_id" {
#  value = module.dns.zone_id
#
