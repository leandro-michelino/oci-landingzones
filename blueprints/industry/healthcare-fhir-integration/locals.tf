locals {
  blueprint_name = "industry-healthcare-fhir-integration"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
  tags           = merge(var.freeform_tags, { Blueprint = local.blueprint_name, ManagedBy = "terraform" })
  foundation     = var.enable_foundation && var.costs_approved
  api            = local.foundation && var.enable_api && var.fhir_backend_url != null && var.fhir_backend_authorization_ready && var.jwks_uri != null && var.drg_id != null && length(var.hospital_client_cidrs) > 0 && length(var.fhir_backend_cidrs) > 0 && length(var.jwks_cidrs) > 0 && length(var.jwt_issuers) > 0 && length(var.jwt_audiences) > 0
  queue          = local.foundation && var.enable_queue && var.kms_key_id != null && var.kms_policies_ready
  remote_cidrs   = setunion(var.hospital_client_cidrs, var.fhir_backend_cidrs, var.jwks_cidrs)
  ranges = { for name, cidr in merge({ vcn = var.vcn_cidr }, var.subnet_cidrs) : name => {
    first = try(sum([for i, octet in split(".", cidrhost(cidr, 0)) : tonumber(octet) * pow(256, 3 - i)]), -1)
    last  = try(sum([for i, octet in split(".", cidrhost(cidr, -1)) : tonumber(octet) * pow(256, 3 - i)]), -1)
  } }
  routes = merge(
    { metadata = { path = "/metadata", methods = toset(["GET"]), backend_path = "metadata" } },
    { for name in var.fhir_resources : "${name}-collection" => { path = "/${name}", methods = setintersection(var.allowed_methods, toset(["GET", "POST"])), backend_path = name } },
    { for name in var.fhir_resources : "${name}-instance" => { path = "/${name}/{id}", methods = setintersection(var.allowed_methods, toset(["GET", "PUT", "PATCH"])), backend_path = "${name}/$${request.path[id]}" } }
  )
}
