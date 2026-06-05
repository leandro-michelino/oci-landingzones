data "oci_objectstorage_namespace" "this" {
  compartment_id = local.target_compartment_ocid
}

resource "oci_objectstorage_bucket" "asset" {
  count = var.create_asset_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = local.namespace
  name                  = local.asset_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = var.bucket_storage_tier
  versioning            = var.bucket_versioning
  auto_tiering          = var.bucket_auto_tiering
  object_events_enabled = var.object_events_enabled
  kms_key_id            = var.kms_key_id
  metadata              = var.bucket_metadata
  defined_tags          = local.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_objectstorage_object" "sample" {
  for_each = var.create_sample_objects ? local.sample_objects : {}

  namespace                  = local.namespace
  bucket                     = local.bucket_name
  object                     = each.value.object_name
  content                    = each.value.content
  content_type               = try(each.value.content_type, null)
  cache_control              = try(each.value.cache_control, null)
  content_disposition        = try(each.value.content_disposition, null)
  content_encoding           = try(each.value.content_encoding, null)
  content_language           = try(each.value.content_language, null)
  metadata                   = try(each.value.metadata, {})
  storage_tier               = try(each.value.storage_tier, "Standard")
  opc_sse_kms_key_id         = var.kms_key_id
  delete_all_object_versions = true

  depends_on = [oci_objectstorage_bucket.asset]
}

resource "oci_objectstorage_preauthrequest" "this" {
  for_each = var.preauth_requests

  namespace             = local.namespace
  bucket                = local.bucket_name
  name                  = coalesce(each.value.name, "${local.name_prefix}-bkt-par-${each.key}")
  access_type           = each.value.access_type
  object_name           = each.value.object_name
  bucket_listing_action = each.value.bucket_listing_action
  time_expires          = each.value.time_expires

  depends_on = [
    oci_objectstorage_bucket.asset,
    oci_objectstorage_object.sample
  ]
}

resource "oci_objectstorage_object_lifecycle_policy" "this" {
  count = var.create_lifecycle_policy && length(var.lifecycle_rules) > 0 ? 1 : 0

  namespace = local.namespace
  bucket    = local.bucket_name

  dynamic "rules" {
    for_each = var.lifecycle_rules

    content {
      name        = coalesce(rules.value.name, "${local.name_prefix}-bkt-lifecycle-${rules.key}")
      action      = rules.value.action
      is_enabled  = rules.value.is_enabled
      time_amount = tostring(rules.value.time_amount)
      time_unit   = rules.value.time_unit
      target      = rules.value.target

      dynamic "object_name_filter" {
        for_each = length(rules.value.inclusion_patterns) > 0 || length(rules.value.exclusion_patterns) > 0 || length(rules.value.inclusion_prefixes) > 0 ? [rules.value] : []

        content {
          inclusion_patterns = object_name_filter.value.inclusion_patterns
          exclusion_patterns = object_name_filter.value.exclusion_patterns
          inclusion_prefixes = object_name_filter.value.inclusion_prefixes
        }
      }
    }
  }

  depends_on = [oci_objectstorage_bucket.asset]
}

resource "oci_dns_rrset" "cdn_cname" {
  count = var.create_dns_cname ? 1 : 0

  zone_name_or_id = var.dns_zone_name_or_id
  domain          = var.cdn_hostname
  rtype           = "CNAME"

  items {
    domain = var.cdn_hostname
    rtype  = "CNAME"
    rdata  = var.cdn_target_hostname
    ttl    = var.dns_ttl
  }
}

resource "cloudflare_dns_record" "cdn" {
  count = var.create_cloudflare_dns_record ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_record_name
  type    = var.cloudflare_record_type
  content = var.cloudflare_record_content
  ttl     = var.cloudflare_record_ttl
  proxied = var.cloudflare_record_proxied
  comment = coalesce(var.cloudflare_record_comment, "Managed by OCI Landing Zones ${local.blueprint_name} blueprint.")
  tags    = var.cloudflare_record_tags
}

resource "cloudflare_ruleset" "cache_static_assets" {
  count = var.create_cloudflare_cache_ruleset ? 1 : 0

  zone_id     = var.cloudflare_zone_id
  name        = coalesce(var.cloudflare_cache_ruleset_name, "${local.name_prefix}-bkt-cache-static-assets")
  description = var.cloudflare_cache_ruleset_description
  kind        = "zone"
  phase       = "http_request_cache_settings"

  rules = [
    {
      action      = "set_cache_settings"
      description = var.cloudflare_cache_rule_description
      enabled     = true
      expression  = local.cloudflare_cache_expression
      ref         = "cache_static_assets"
      action_parameters = {
        cache                = true
        origin_cache_control = var.cloudflare_origin_cache_control
        browser_ttl = {
          mode    = var.cloudflare_browser_ttl_mode
          default = var.cloudflare_browser_ttl_seconds
        }
        edge_ttl = {
          mode    = var.cloudflare_edge_ttl_mode
          default = var.cloudflare_edge_ttl_seconds
        }
        serve_stale = {
          disable_stale_while_updating = var.cloudflare_disable_stale_while_updating
        }
      }
    }
  ]
}

resource "cloudflare_ruleset" "origin_route" {
  count = var.create_cloudflare_origin_ruleset ? 1 : 0

  zone_id     = var.cloudflare_zone_id
  name        = coalesce(var.cloudflare_origin_ruleset_name, "${local.name_prefix}-bkt-origin-objectstorage")
  description = var.cloudflare_origin_ruleset_description
  kind        = "zone"
  phase       = "http_request_origin"

  rules = [
    {
      action      = "route"
      description = var.cloudflare_origin_rule_description
      enabled     = true
      expression  = local.cloudflare_origin_expression
      ref         = "route_oci_object_storage_origin"
      action_parameters = {
        origin = {
          host = local.cloudflare_origin_host
        }
        host_header = coalesce(var.cloudflare_host_header, local.cloudflare_origin_host)
        sni = {
          value = coalesce(var.cloudflare_sni, local.cloudflare_origin_host)
        }
      }
    }
  ]
}

resource "cloudflare_workers_script" "oci_asset_proxy" {
  count = var.create_cloudflare_worker_proxy ? 1 : 0

  account_id         = var.cloudflare_account_id
  script_name        = local.cloudflare_worker_script_name
  main_module        = "worker.js"
  compatibility_date = var.cloudflare_worker_compatibility_date
  content            = local.cloudflare_worker_content

  bindings = [
    {
      name = "OCI_PAR_URL"
      type = "secret_text"
      text = local.cloudflare_worker_upstream_url
    },
    {
      name = "CACHE_TTL_SECONDS"
      type = "plain_text"
      text = tostring(var.cloudflare_worker_cache_ttl_seconds)
    },
    {
      name = "WORKER_CACHE_CONTROL"
      type = "plain_text"
      text = var.cloudflare_worker_response_cache_control
    }
  ]

  depends_on = [
    oci_objectstorage_preauthrequest.this
  ]
}

resource "cloudflare_workers_route" "oci_asset_proxy" {
  count = var.create_cloudflare_worker_proxy ? 1 : 0

  zone_id = var.cloudflare_zone_id
  pattern = local.cloudflare_worker_route_pattern
  script  = cloudflare_workers_script.oci_asset_proxy[0].script_name
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-pol-cdn-assets"
  description    = "CDN static asset distribution access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = local.defined_tags
  freeform_tags  = local.common_freeform_tags
}
