# Last successful validation: 2026-10-14 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Scope: schema validation only; full live lifecycle not verified.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
resource "oci_containerengine_addon" "service_mesh" {
  count = var.enable_service_mesh_addon ? 1 : 0

  cluster_id                       = var.cluster_id
  addon_name                       = var.addon_name
  version                          = var.addon_version
  override_existing                = var.override_existing
  remove_addon_resources_on_delete = var.remove_addon_resources_on_delete

  dynamic "configurations" {
    for_each = var.addon_configurations

    content {
      key   = configurations.value.key
      value = configurations.value.value
    }
  }
}

resource "oci_apm_apm_domain" "tracing" {
  count = var.enable_apm_domain ? 1 : 0

  compartment_id = local.target_compartment_ocid
  display_name   = local.apm_domain_name
  description    = var.apm_domain_description
  is_free_tier   = var.apm_is_free_tier
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
