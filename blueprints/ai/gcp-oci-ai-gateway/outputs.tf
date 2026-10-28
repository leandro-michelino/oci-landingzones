output "blueprint_name" {
  description = "Stable blueprint identifier."
  value       = "ai-gcp-oci-ai-gateway"
}

output "resource_ids" {
  description = "Private OCI gateway/deployment IDs; adapters enforce caller identity."
  value       = module.gateway.resource_ids
}
