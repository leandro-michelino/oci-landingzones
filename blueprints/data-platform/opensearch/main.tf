# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
data "oci_objectstorage_namespace" "this" {
  count          = var.create_snapshot_bucket ? 1 : 0
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "snapshots" {
  count = var.create_snapshot_bucket ? 1 : 0

  compartment_id        = local.target_compartment_ocid
  namespace             = data.oci_objectstorage_namespace.this[0].namespace
  name                  = local.snapshot_bucket_name
  access_type           = "NoPublicAccess"
  storage_tier          = "Standard"
  versioning            = var.snapshot_bucket_versioning
  object_events_enabled = true
  kms_key_id            = var.kms_key_id
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

resource "oci_opensearch_opensearch_cluster" "this" {
  count = var.create_cluster ? 1 : 0

  compartment_id                     = local.target_compartment_ocid
  display_name                       = local.cluster_display_name
  software_version                   = var.software_version
  vcn_id                             = var.vcn_id
  vcn_compartment_id                 = coalesce(var.vcn_compartment_id, local.target_compartment_ocid)
  subnet_id                          = var.subnet_id
  subnet_compartment_id              = coalesce(var.subnet_compartment_id, local.target_compartment_ocid)
  nsg_id                             = var.nsg_id
  master_node_count                  = var.master_node_count
  master_node_host_type              = var.master_node_host_type
  master_node_host_ocpu_count        = var.master_node_host_ocpu_count
  master_node_host_memory_gb         = var.master_node_host_memory_gb
  data_node_count                    = var.data_node_count
  data_node_host_type                = var.data_node_host_type
  data_node_host_ocpu_count          = var.data_node_host_ocpu_count
  data_node_host_memory_gb           = var.data_node_host_memory_gb
  data_node_storage_gb               = var.data_node_storage_gb
  opendashboard_node_count           = var.opendashboard_node_count
  opendashboard_node_host_ocpu_count = var.opendashboard_node_host_ocpu_count
  opendashboard_node_host_memory_gb  = var.opendashboard_node_host_memory_gb
  opendashboard_node_host_shape      = var.opendashboard_node_host_shape
  security_master_user_name          = var.security_master_user_name
  security_master_user_password_hash = var.security_master_user_password_hash
  security_mode                      = var.security_mode
  defined_tags                       = var.defined_tags
  freeform_tags                      = local.common_freeform_tags
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  provider       = oci.home
  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-access"
  description    = "OpenSearch access policy for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
