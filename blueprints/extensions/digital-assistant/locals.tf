# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "extensions-digital-assistant"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)

  oda_vcn_name    = "${local.name_prefix}-vcn-oda"
  oda_igw_name    = "${local.name_prefix}-igw-oda"
  oda_rt_name     = "${local.name_prefix}-rt-oda"
  oda_sl_name     = "${local.name_prefix}-sl-oda"
  oda_subnet_name = "${local.name_prefix}-sn-oda"
  oda_nsg_name    = "${local.name_prefix}-nsg-oda"

  oda_display_name          = coalesce(var.oda_display_name, "${local.name_prefix}-app-oda")
  oda_private_endpoint_name = coalesce(var.oda_private_endpoint_display_name, "${local.name_prefix}-pe-oda")
  alert_topic_name          = coalesce(var.alert_topic_name, "${local.name_prefix}-top-oda-alert")

  oda_instance_id_effective = var.create_oda_instance ? try(oci_oda_oda_instance.this[0].id, null) : var.oda_instance_id

  oda_private_endpoint_subnet_id_effective = var.enable_oda_network ? try(oci_core_subnet.oda[0].id, null) : var.oda_private_endpoint_subnet_id

  oda_private_endpoint_nsg_ids_effective = var.enable_oda_network ? toset(
    concat(
      [oci_core_network_security_group.oda[0].id],
      tolist(var.oda_private_endpoint_additional_nsg_ids)
    )
  ) : var.oda_private_endpoint_additional_nsg_ids

  oda_private_endpoint_id_effective = var.create_oda_private_endpoint ? try(oci_oda_oda_private_endpoint.this[0].id, null) : var.oda_private_endpoint_id

  common_freeform_tags = merge(
    {
      Blueprint = local.blueprint_name
      ManagedBy = "terraform"
    },
    var.freeform_tags
  )
}
