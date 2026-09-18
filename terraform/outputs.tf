output "vpc_id" {
  description = "ID VPC tier non-core."
  value       = module.network_zones.vpc_id
}

output "subnet_ids" {
  description = "ID subnet per zona. Core zone sengaja tidak ada di sini (on-premise, ADR-01)."
  value       = module.network_zones.subnet_ids
}

output "security_group_ids" {
  description = "ID security group per zona untuk referensi resource berikutnya."
  value       = module.zone_security.security_group_ids
}

output "admin_cidr_used" {
  description = "CIDR administratif yang dikonfigurasi (jangan pernah 0.0.0.0/0)."
  value       = var.admin_cidr
}