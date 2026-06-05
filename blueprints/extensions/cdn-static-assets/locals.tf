locals {
  blueprint_name          = "cdn-static-assets"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  defined_tags            = length(var.defined_tags) > 0 ? var.defined_tags : null

  namespace         = data.oci_objectstorage_namespace.this.namespace
  asset_bucket_name = coalesce(var.asset_bucket_name, lower(replace("${local.name_prefix}-bkt-assets-origin", "_", "-")))
  bucket_name       = var.create_asset_bucket ? oci_objectstorage_bucket.asset[0].name : var.existing_asset_bucket_name

  object_storage_endpoint = "https://objectstorage.${var.region}.oraclecloud.com"
  origin_base_url         = local.bucket_name == null ? null : "${local.object_storage_endpoint}/n/${local.namespace}/b/${local.bucket_name}/o"
  origin_path             = local.bucket_name == null ? null : "/n/${local.namespace}/b/${local.bucket_name}/o/"
  cloudflare_cache_host   = coalesce(var.cloudflare_cache_hostname, var.cdn_hostname, var.cloudflare_record_name)
  cloudflare_origin_host  = coalesce(var.cloudflare_origin_host, "objectstorage.${var.region}.oraclecloud.com")
  cloudflare_cache_expression = coalesce(
    var.cloudflare_cache_rule_expression,
    "(http.host eq \"${local.cloudflare_cache_host}\" and starts_with(http.request.uri.path, \"${var.cloudflare_cache_path_prefix}\"))"
  )
  cloudflare_origin_expression = coalesce(
    var.cloudflare_origin_rule_expression,
    "http.host eq \"${local.cloudflare_cache_host}\""
  )
  cloudflare_worker_script_name = coalesce(var.cloudflare_worker_script_name, lower(replace("${local.name_prefix}-fn-oci-asset-proxy", "_", "-")))
  cloudflare_worker_route_pattern = coalesce(
    var.cloudflare_worker_route_pattern,
    local.cloudflare_cache_host == null ? null : "${local.cloudflare_cache_host}${var.cloudflare_worker_smoke_path}*"
  )
  cloudflare_worker_upstream_url = coalesce(
    var.cloudflare_worker_upstream_url,
    var.cloudflare_worker_upstream_preauth_key == null ? null : try("${local.object_storage_endpoint}${oci_objectstorage_preauthrequest.this[var.cloudflare_worker_upstream_preauth_key].access_uri}", null)
  )
  cloudflare_worker_smoke_url = local.cloudflare_cache_host == null ? null : "https://${local.cloudflare_cache_host}${var.cloudflare_worker_smoke_path}"
  cloudflare_worker_content   = <<-EOT
    export default {
      async fetch(request, env, ctx) {
        if (request.method !== "GET" && request.method !== "HEAD") {
          return new Response("Method not allowed", { status: 405 });
        }

        if (!env.OCI_PAR_URL) {
          return new Response("Missing upstream configuration", { status: 500 });
        }

        const ttl = Number.parseInt(env.CACHE_TTL_SECONDS || "300", 10);
        const requestUrl = new URL(request.url);
        const cacheKey = new Request(`$${requestUrl.origin}$${requestUrl.pathname}`, { method: "GET" });
        const cache = caches.default;
        const cached = await cache.match(cacheKey);
        if (cached) {
          const headers = new Headers(cached.headers);
          headers.set("X-OCI-LZ-Cloudflare-Proxy", "worker");
          headers.set("X-OCI-LZ-Cloudflare-Cache", "hit");
          return new Response(cached.body, {
            status: cached.status,
            statusText: cached.statusText,
            headers
          });
        }

        const upstreamResponse = await fetch(env.OCI_PAR_URL, {
          cf: {
            cacheEverything: true,
            cacheTtl: ttl
          }
        });
        const headers = new Headers(upstreamResponse.headers);
        headers.set("Cache-Control", env.WORKER_CACHE_CONTROL || `public, max-age=$${ttl}`);
        headers.set("X-OCI-LZ-Cloudflare-Proxy", "worker");
        headers.set("X-OCI-LZ-Cloudflare-Cache", "miss");

        const response = new Response(upstreamResponse.body, {
          status: upstreamResponse.status,
          statusText: upstreamResponse.statusText,
          headers
        });

        if (upstreamResponse.ok) {
          ctx.waitUntil(cache.put(cacheKey, response.clone()));
        }

        return response;
      }
    };
  EOT

  default_sample_objects = {
    public_index = {
      object_name         = "public/index.html"
      content             = <<-EOT
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>OCI static asset sample</title>
          <link rel="stylesheet" href="app.css">
        </head>
        <body>
          <h1>OCI static asset sample</h1>
          <p>This object is safe to cache at the edge when the CDN origin model is approved.</p>
        </body>
        </html>
      EOT
      content_type        = "text/html; charset=utf-8"
      cache_control       = "public, max-age=300, stale-while-revalidate=60"
      content_disposition = null
      content_encoding    = null
      content_language    = "en"
      metadata            = { classification = "public-cacheable" }
      storage_tier        = "Standard"
    }
    public_css = {
      object_name         = "public/app.css"
      content             = <<-EOT
        body {
          color: #111827;
          font-family: Arial, sans-serif;
          margin: 2rem;
        }
      EOT
      content_type        = "text/css; charset=utf-8"
      cache_control       = "public, max-age=86400, immutable"
      content_disposition = null
      content_encoding    = null
      content_language    = "en"
      metadata            = { classification = "public-cacheable" }
      storage_tier        = "Standard"
    }
    private_statement = {
      object_name         = "private/demo-statement.txt"
      content             = "Synthetic statement for PAR smoke tests. Do not store real customer data in repository samples.\n"
      content_type        = "text/plain; charset=utf-8"
      cache_control       = "private, no-store"
      content_disposition = "attachment; filename=\"demo-statement.txt\""
      content_encoding    = null
      content_language    = "en"
      metadata            = { classification = "private-par-only" }
      storage_tier        = "Standard"
    }
    public_cloudflare_smoke = {
      object_name         = "public/cloudflare-smoke.txt"
      content             = "Synthetic Cloudflare smoke test asset for OCI Object Storage origin validation.\n"
      content_type        = "text/plain; charset=utf-8"
      cache_control       = "public, max-age=300, stale-while-revalidate=60"
      content_disposition = null
      content_encoding    = null
      content_language    = "en"
      metadata            = { classification = "public-cacheable-smoke-test" }
      storage_tier        = "Standard"
    }
  }

  sample_objects = merge(local.default_sample_objects, var.sample_objects)

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
