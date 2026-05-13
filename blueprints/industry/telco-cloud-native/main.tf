# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "network" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns?ref=v0.2.0"

  tenancy_ocid       = var.tenancy_ocid
  current_user_ocid  = var.current_user_ocid
  region             = var.region
  home_region        = var.home_region
  oci_config_profile = var.oci_config_profile
  compartment_ocid   = local.target_compartment_ocid
  org                = var.org
  environment        = var.environment
  region_key         = var.region_key
  defined_tags       = var.defined_tags
  freeform_tags      = local.common_freeform_tags
}

module "vault" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/security/vault?ref=v0.2.0"

  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = local.target_compartment_ocid
  region               = var.region
  org                  = var.org
  environment          = var.environment
  region_key           = var.region_key
  enable_vault         = var.enable_vault
  enable_default_vault = var.enable_default_vault
  enable_default_key   = var.enable_default_key
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags
}

module "oke" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//blueprints/extensions/oke?ref=v0.2.0"

  tenancy_ocid             = var.tenancy_ocid
  current_user_ocid        = var.current_user_ocid
  region                   = var.region
  home_region              = var.home_region
  oci_config_profile       = var.oci_config_profile
  compartment_ocid         = local.target_compartment_ocid
  org                      = var.org
  environment              = var.environment
  region_key               = var.region_key
  enable_cluster           = var.enable_oke_cluster
  enable_node_pool         = var.enable_oke_node_pool
  cluster_label            = var.cluster_label
  kubernetes_version       = var.kubernetes_version
  vcn_id                   = module.network.hub_vcn_id
  endpoint_subnet_id       = try(module.network.hub_subnet_ids[var.oke_endpoint_subnet_key], null)
  service_lb_subnet_ids    = compact([try(module.network.hub_subnet_ids[var.oke_service_lb_subnet_key], null)])
  node_subnet_ids          = toset(compact([try(module.network.hub_subnet_ids[var.oke_node_subnet_key], null)]))
  node_shape               = var.node_shape
  node_shape_ocpus         = var.node_shape_ocpus
  node_shape_memory_in_gbs = var.node_shape_memory_in_gbs
  ssh_public_key           = var.ssh_public_key
  defined_tags             = var.defined_tags
  freeform_tags            = local.common_freeform_tags
}

module "monitoring" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/operations/monitoring?ref=v0.2.0"

  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = local.target_compartment_ocid
  region               = var.region
  org                  = var.org
  environment          = var.environment
  region_key           = var.region_key
  enable_monitoring    = var.enable_monitoring
  enable_default_topic = var.enable_default_monitoring_topic
  notification_topics  = var.monitoring_notification_topics
  subscriptions        = var.monitoring_subscriptions
  alarms               = var.monitoring_alarms
  defined_tags         = var.defined_tags
  freeform_tags        = local.common_freeform_tags
}

module "os_management" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/operations/os-management?ref=v0.2.0"

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.target_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  enable_os_management    = var.enable_os_management
  managed_instance_groups = var.os_managed_instance_groups
  scheduled_jobs          = var.os_scheduled_jobs
  defined_tags            = var.defined_tags
  freeform_tags           = local.common_freeform_tags
}
