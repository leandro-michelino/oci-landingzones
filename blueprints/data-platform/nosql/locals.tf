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
  nosql_sql_prefix = "${var.org}_${var.environment}_${var.region_key}"
  nosql_table_name = coalesce(var.table_name, "${local.nosql_sql_prefix}_db_nosql_orders")
  nosql_index_name = coalesce(var.secondary_index_name, "${local.nosql_sql_prefix}_db_nosql_customer")
  nosql_table_ddl  = coalesce(var.table_ddl_statement, "CREATE TABLE ${local.nosql_table_name} (id STRING, customerId STRING, payload JSON, PRIMARY KEY(id))")
  alert_topic_name = coalesce(var.alert_topic_name, "${local.name_prefix}-top-nosql-alert")

  common_freeform_tags = merge(
    {
      Blueprint = local.blueprint_name
      ManagedBy = "terraform"
    },
    var.freeform_tags
  )
}
