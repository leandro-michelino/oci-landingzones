# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "groups" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/groups?ref=v0.2.0"

  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = local.target_compartment_ocid
  region                = var.region
  org                   = var.org
  environment           = var.environment
  region_key            = var.region_key
  cis_level             = local.cis_level
  enable_default_groups = var.enable_default_groups
  groups                = var.groups
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

module "dynamic_groups" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/dynamic-groups?ref=v0.2.0"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.target_compartment_ocid
  region           = var.region
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  cis_level        = local.cis_level
  dynamic_groups   = var.dynamic_groups
  defined_tags     = var.defined_tags
  freeform_tags    = local.common_freeform_tags
}

module "policies" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/policies?ref=v0.2.0"

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.target_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  cis_level               = local.cis_level
  enable_default_policies = false
  group_names             = module.groups.group_names
  dynamic_group_names     = module.dynamic_groups.dynamic_group_names
  policies                = merge(local.default_cis_policies, var.policies)
  defined_tags            = var.defined_tags
  freeform_tags           = local.common_freeform_tags
}
