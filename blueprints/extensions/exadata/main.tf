# Last successful validation: 2026-10-17 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: blueprint schema validation only; no live workload or end-to-end test.
# Evidence: docs/EXTENSIONS-REVIEW-20261017.md; ignored local logs where applicable.
resource "oci_database_cloud_exadata_infrastructure" "this" {
  count = var.enable_exadata_infrastructure ? 1 : 0

  availability_domain  = var.availability_domain
  compartment_id       = local.target_compartment_ocid
  display_name         = local.infrastructure_name
  shape                = var.shape
  compute_count        = var.compute_count
  storage_count        = var.storage_count
  database_server_type = var.database_server_type
  storage_server_type  = var.storage_server_type
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags

  dynamic "customer_contacts" {
    for_each = var.customer_contacts

    content {
      email = customer_contacts.value.email
    }
  }
}
