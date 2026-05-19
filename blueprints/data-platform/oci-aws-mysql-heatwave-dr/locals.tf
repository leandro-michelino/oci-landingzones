# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "oci-aws-mysql-heatwave-dr"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  db_vcn_name         = "${local.name_prefix}-vcn-mysql-primary"
  db_subnet_name      = "${local.name_prefix}-sn-mysql-primary"
  db_route_table_name = "${local.name_prefix}-rt-mysql-primary"
  db_security_name    = "${local.name_prefix}-sl-mysql-primary"
  db_igw_name         = "${local.name_prefix}-igw-mysql-primary"
  drg_name            = "${local.name_prefix}-drg-mysql-primary"
  drg_attachment_name = "${local.name_prefix}-drga-mysql-primary"
  cpe_name            = "${local.name_prefix}-cpe-aws"
  ipsec_name          = "${local.name_prefix}-vpn-aws"

  db_system_display_name = "${local.name_prefix}-db-mysql-primary"
  lakehouse_bucket_name  = coalesce(var.lakehouse_bucket_name, "${local.name_prefix}-bkt-lakehouse")
  alert_topic_name       = coalesce(var.dr_alert_topic_name, "${local.name_prefix}-top-mysql-dr-alert")

  db_subnet_id_effective = var.enable_oci_primary_network ? try(oci_core_subnet.primary_db[0].id, null) : null
  db_system_id_effective = var.create_db_system ? try(oci_mysql_mysql_db_system.primary[0].id, null) : var.existing_db_system_id
  heatwave_id_effective  = var.create_heatwave_cluster ? try(oci_mysql_heat_wave_cluster.primary[0].id, null) : var.existing_heatwave_cluster_id

  oci_network_contract = {
    oci_is_primary      = true
    vcn_id              = try(oci_core_vcn.primary[0].id, null)
    subnet_id           = local.db_subnet_id_effective
    route_table_id      = try(oci_core_route_table.primary_db[0].id, null)
    security_list_id    = try(oci_core_security_list.primary_db[0].id, null)
    drg_id              = try(oci_core_drg.primary[0].id, null)
    drg_attachment_id   = try(oci_core_drg_attachment.primary_db[0].id, null)
    ipsec_connection_id = try(oci_core_ipsec.aws[0].id, null)
  }

  connectivity_contract = {
    mode                  = "ipsec"
    oci_drg_id            = try(oci_core_drg.primary[0].id, null)
    aws_cpe_public_ip     = var.aws_cpe_public_ip
    aws_bgp_asn           = var.aws_bgp_asn
    ipsec_connection_id   = try(oci_core_ipsec.aws[0].id, null)
    ipsec_tunnel_count    = var.enable_ipsec_connectivity ? 2 : 0
    aws_replication_cidrs = [var.aws_replication_cidr]
  }

  replication_contract = {
    channel_name          = var.replication_channel_name
    source_cloud          = "oci"
    target_cloud          = "aws"
    source_endpoint       = var.oci_primary_endpoint
    target_endpoint       = var.aws_secondary_endpoint
    replication_user_name = var.replication_user_name
    ssl_required          = var.replication_ssl_required
    target_rpo_minutes    = var.target_rpo_minutes
  }

  dns_failover_contract = {
    primary_dns_name          = var.primary_dns_name
    primary_cloud             = "oci"
    secondary_cloud           = "aws"
    primary_endpoint          = var.oci_primary_endpoint
    secondary_endpoint        = var.aws_secondary_endpoint
    ttl_seconds               = var.dns_ttl_seconds
    cutover_requires_approval = true
  }

  runbook_contract = {
    oci_is_primary      = true
    replication_channel = var.replication_channel_name
    drill_frequency     = var.dr_drill_frequency
    target_rto_minutes  = var.target_rto_minutes
    target_rpo_minutes  = var.target_rpo_minutes
    failover_sequence   = ["freeze-writes", "verify-replication", "promote-aws-secondary", "switch-dns", "validate-app-health"]
    failback_sequence   = ["restore-oci-primary", "reverse-replication", "promote-oci-primary", "switch-dns-back", "validate-data-consistency"]
  }

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
