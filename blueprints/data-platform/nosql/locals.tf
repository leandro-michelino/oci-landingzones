locals {
  blueprint_name          = "data-platform-nosql"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)

  app_vcn_name     = "${local.name_prefix}-vcn-nosql-app"
  app_igw_name     = "${local.name_prefix}-igw-nosql-app"
  app_rt_name      = "${local.name_prefix}-rt-nosql-app"
  app_sl_name      = "${local.name_prefix}-sl-nosql-app"
  app_subnet_name  = "${local.name_prefix}-sn-nosql-app"
  nosql_table_name = coalesce(var.table_name, "${local.name_prefix}-db-nosql-orders")
  nosql_index_name = coalesce(var.secondary_index_name, "${local.name_prefix}-db-nosql-customer")
  alert_topic_name = coalesce(var.alert_topic_name, "${local.name_prefix}-top-nosql-alert")

  common_freeform_tags = merge(
    {
      Blueprint = local.blueprint_name
      ManagedBy = "terraform"
    },
    var.freeform_tags
  )
}
