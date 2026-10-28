output "network_id" {
  description = "Created VPC ID."
  value       = module.network.network_id
}

output "subnet_id" {
  description = "Created private subnet ID."
  value       = module.network.subnet_id
}

output "pairing_keys" {
  description = "Provider pairing keys for private handoff; do not publish values."
  value       = { for k, v in google_compute_interconnect_attachment.this : k => v.pairing_key }
}

output "ha_vpn_public_ips" {
  description = "Assigned GCP public interface addresses for OCI CPE handoff."
  value       = try({ for i in google_compute_ha_vpn_gateway.this[0].vpn_interfaces : tostring(i.id) => i.ip_address }, {})
}
