# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "compartments" {
  source = "../../modules/iam/compartments"

  providers = {
    oci = oci.home
  }

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.parent_compartment_ocid
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  cis_level        = var.cis_level
  enable_delete    = var.enable_delete
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags
}

module "tagging" {
  source = "../../modules/governance/tagging"

  providers = {
    oci = oci.home
  }

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = module.compartments.compartment_ids["governance"]
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  cis_level                   = var.cis_level
  enable_tagging              = var.enable_tagging
  enable_tag_defaults         = var.enable_tag_defaults
  tag_namespace_name          = var.tag_namespace_name
  tag_default_compartment_ids = module.compartments.compartment_ids
  tag_default_values          = local.core_tag_default_values
  required_tag_defaults       = var.required_tag_defaults
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags
}

module "logging" {
  source = "../../modules/governance/logging"

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = module.compartments.compartment_ids["governance"]
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  cis_level                   = var.cis_level
  enable_logging              = var.enable_logging
  log_groups                  = var.log_groups
  service_logs                = var.service_logs
  vcn_flow_logs               = var.vcn_flow_logs
  saved_searches              = var.logging_saved_searches
  enable_audit_retention      = var.enable_audit_retention
  audit_retention_period_days = var.audit_retention_period_days
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags
}

module "cloud_guard" {
  source = "../../modules/security/cloud-guard"

  tenancy_ocid                = var.tenancy_ocid
  compartment_ocid            = module.compartments.compartment_ids["security"]
  region                      = var.region
  org                         = var.org
  environment                 = var.environment
  region_key                  = var.region_key
  cis_level                   = var.cis_level
  enable_cloud_guard          = var.cloud_guard_enabled
  cloud_guard_status          = var.cloud_guard_status
  reporting_region            = var.cloud_guard_reporting_region
  self_manage_resources       = var.cloud_guard_self_manage_resources
  enable_default_target       = var.cloud_guard_enable_default_target
  target_resource_ocid        = module.compartments.root_compartment_id
  target_resource_type        = "COMPARTMENT"
  target_detector_recipe_ids  = var.cloud_guard_detector_recipe_ids
  target_responder_recipe_ids = var.cloud_guard_responder_recipe_ids
  targets                     = var.cloud_guard_targets
  defined_tags                = var.defined_tags
  freeform_tags               = var.freeform_tags
}

module "groups" {
  source = "../../modules/iam/groups"

  providers = {
    oci = oci.home
  }

  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = var.tenancy_ocid
  region                = var.region
  org                   = var.org
  environment           = var.environment
  region_key            = var.region_key
  cis_level             = var.cis_level
  enable_default_groups = var.enable_default_iam_groups
  groups                = var.iam_groups
  defined_tags          = var.defined_tags
  freeform_tags         = var.freeform_tags
}

module "dynamic_groups" {
  source = "../../modules/iam/dynamic-groups"

  providers = {
    oci = oci.home
  }

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.tenancy_ocid
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  cis_level        = var.cis_level
  dynamic_groups   = local.core_dynamic_groups
  defined_tags     = var.defined_tags
  freeform_tags    = var.freeform_tags
}

module "policies" {
  source = "../../modules/iam/policies"

  providers = {
    oci = oci.home
  }

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.parent_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  cis_level               = var.cis_level
  enable_default_policies = var.enable_default_iam_policies
  group_names             = module.groups.group_names
  dynamic_group_names     = module.dynamic_groups.dynamic_group_names
  compartment_names       = module.compartments.compartment_names
  policies                = var.iam_policies
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}
