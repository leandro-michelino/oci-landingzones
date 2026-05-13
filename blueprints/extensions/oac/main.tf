# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_analytics_analytics_instance" "this" {
  count = var.enable_analytics_instance ? 1 : 0

  compartment_id     = local.target_compartment_ocid
  name               = local.analytics_instance_name
  description        = var.description
  feature_set        = var.feature_set
  license_type       = var.license_type
  email_notification = var.email_notification
  kms_key_id         = var.kms_key_id
  domain_id          = var.domain_id
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags

  capacity {
    capacity_type  = var.capacity_type
    capacity_value = var.capacity_value
  }
}

resource "oci_analytics_analytics_instance_private_access_channel" "this" {
  count = var.enable_private_access_channel ? 1 : 0

  analytics_instance_id      = local.analytics_instance_id
  display_name               = local.private_access_channel_name
  vcn_id                     = var.vcn_id
  subnet_id                  = var.subnet_id
  network_security_group_ids = var.network_security_group_ids

  dynamic "private_source_dns_zones" {
    for_each = var.private_source_dns_zones

    content {
      dns_zone    = private_source_dns_zones.value.dns_zone
      description = try(private_source_dns_zones.value.description, null)
    }
  }
}
