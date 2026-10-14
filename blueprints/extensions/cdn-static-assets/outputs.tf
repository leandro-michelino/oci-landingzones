output "blueprint_name" {
  description = "Stable blueprint deployment identifier used for reporting, runbooks, and cross-blueprint automation hand-offs."
  value       = local.blueprint_name
}
output "name_prefix" {
  description = "Resolved OCI naming prefix applied to resources and contracts in this blueprint."
  value       = local.name_prefix
}
output "namespace" {
  description = "Object Storage namespace used by the asset origin."
  value       = local.namespace
}
output "resource_ids" {
  description = "Map of resource identifiers created or referenced by this blueprint."
  value = {
    asset_bucket              = try(oci_objectstorage_bucket.asset[0].id, null)
    lifecycle_policy          = try(oci_objectstorage_object_lifecycle_policy.this[0].id, null)
    preauth_requests          = { for key, par in oci_objectstorage_preauthrequest.this : key => par.id }
    dns_cname_rrset           = try(oci_dns_rrset.cdn_cname[0].id, null)
    cloudflare_dns_record     = try(cloudflare_dns_record.cdn[0].id, null)
    cloudflare_cache_ruleset  = try(cloudflare_ruleset.cache_static_assets[0].id, null)
    cloudflare_origin_ruleset = try(cloudflare_ruleset.origin_route[0].id, null)
    cloudflare_worker_script  = try(cloudflare_workers_script.oci_asset_proxy[0].id, null)
    cloudflare_worker_route   = try(cloudflare_workers_route.oci_asset_proxy[0].id, null)
    access_policy             = try(oci_identity_policy.access[0].id, null)
  }
}
output "asset_bucket_name" {
  description = "Object Storage asset origin bucket name."
  value       = local.bucket_name
}
output "asset_bucket_id" {
  description = "Created Object Storage bucket OCID when this blueprint creates the bucket."
  value       = try(oci_objectstorage_bucket.asset[0].bucket_id, null)
}
output "object_storage_origin_base_url" {
  description = "Object Storage object URL prefix for the asset origin."
  value       = local.origin_base_url
}
output "sample_object_urls" {
  description = "Object Storage API URLs for Terraform-created synthetic samples. They require OCI auth or PAR access because the bucket is private."
  value = var.create_sample_objects ? {
    for key, object in local.sample_objects :
    key => "${local.origin_base_url}/${urlencode(object.object_name)}"
  } : {}
}
output "preauth_request_urls" {
  description = "Full PAR URLs for Terraform-managed smoke-test requests. Treat these as bearer credentials and protect generated output files."
  value = {
    for key, par in oci_objectstorage_preauthrequest.this :
    key => "${local.object_storage_endpoint}${par.access_uri}"
  }
  sensitive = true
}
output "cdn_handoff" {
  description = "Cloudflare at OCI or external CDN integration contract produced by this blueprint."
  value = {
    mode                         = var.cdn_mode
    cdn_hostname                 = var.cdn_hostname
    cloudflare_zone_id           = var.cloudflare_zone_id
    cloudflare_dns_record_id     = try(cloudflare_dns_record.cdn[0].id, null)
    cloudflare_cache_ruleset_id  = try(cloudflare_ruleset.cache_static_assets[0].id, null)
    cloudflare_origin_ruleset_id = try(cloudflare_ruleset.origin_route[0].id, null)
    cloudflare_worker_script_id  = try(cloudflare_workers_script.oci_asset_proxy[0].id, null)
    cloudflare_worker_route_id   = try(cloudflare_workers_route.oci_asset_proxy[0].id, null)
    cloudflare_worker_route      = local.cloudflare_worker_route_pattern
    cloudflare_worker_smoke_url  = local.cloudflare_worker_smoke_url
    cloudflare_cache_expression  = local.cloudflare_cache_expression
    cloudflare_origin_expression = local.cloudflare_origin_expression
    object_storage_origin_host   = "objectstorage.${var.region}.oraclecloud.com"
    object_storage_origin_path   = local.origin_path
    dns_rrset_id                 = try(oci_dns_rrset.cdn_cname[0].id, null)
    recommended_edge             = var.cdn_mode == "cloudflare_at_oci" ? "Provision Cloudflare at OCI through OCI Partner Offerings, then point approved cacheable prefixes or an app origin at this bucket contract." : "Use the external CDN control plane and the origin contract from this output."
    sensitive_document_delivery  = "Use backend-generated short-TTL ObjectRead PARs and Cache-Control: private, no-store."
    cacheable_static_asset_model = "Cache only public-safe static prefixes after the Cloudflare origin access model is approved."
  }
}
output "cloudflare_smoke_test_url" {
  description = "Cloudflare-routed smoke-test URL. Worker mode hides the upstream PAR; origin-rule mode embeds the PAR path and should still be protected."
  value = (
    var.create_cloudflare_worker_proxy
    ? local.cloudflare_worker_smoke_url
    : (
      var.cloudflare_smoke_test_preauth_key == null || local.cloudflare_cache_host == null
      ? null
      : "https://${local.cloudflare_cache_host}${try(oci_objectstorage_preauthrequest.this[var.cloudflare_smoke_test_preauth_key].access_uri, "")}"
    )
  )
  sensitive = true
}
output "access_policy_id" {
  description = "IAM policy OCID for asset distribution access."
  value       = try(oci_identity_policy.access[0].id, null)
}
