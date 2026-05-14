# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name           = "network-load-balancer"
  name_prefix              = lower(join("-", compact([var.org, var.environment, var.region_key, "nlb"])))
  target_compartment_ocid  = coalesce(var.compartment_ocid, var.tenancy_ocid)
  policy_compartment_ocid  = coalesce(var.policy_compartment_ocid, var.tenancy_ocid)
  nlb_display_name         = coalesce(var.network_load_balancer_display_name, "${local.name_prefix}-nlb")
  network_load_balancer_id = var.create_network_load_balancer ? try(oci_network_load_balancer_network_load_balancer.this[0].id, null) : var.network_load_balancer_id

  backend_matrix = merge([
    for backend_set_key, backend_set in var.backend_sets : {
      for backend_key, backend in backend_set.backends : "${backend_set_key}-${backend_key}" => merge(backend, {
        backend_set_key  = backend_set_key
        backend_set_name = coalesce(backend_set.name, "${local.name_prefix}-${backend_set_key}")
      })
    }
  ]...)

  common_freeform_tags = merge(var.freeform_tags, {
    ManagedBy = "Terraform"
    Blueprint = local.blueprint_name
  })
}
