# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
module "entity_compartments" {
  source   = "../../../modules/iam/compartments"
  for_each = local.entities

  providers = {
    oci = oci.home
  }

  tenancy_ocid                 = var.tenancy_ocid
  compartment_ocid             = each.value.parent_compartment_id
  region                       = var.region
  org                          = var.org
  environment                  = var.environment
  region_key                   = var.region_key
  root_compartment_name        = each.value.root_name
  root_compartment_description = "Operating entity root compartment for ${each.value.name}."
  child_compartments           = each.value.child_compartments
  enable_delete                = var.enable_delete
  defined_tags                 = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint       = local.blueprint_name
      OperatingEntity = each.value.name
    }
  )
}

module "groups" {
  source = "../../../modules/iam/groups"

  providers = {
    oci = oci.home
  }

  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = var.tenancy_ocid
  region                = var.region
  org                   = var.org
  environment           = var.environment
  region_key            = var.region_key
  enable_default_groups = false
  groups                = local.group_definitions
  defined_tags          = var.defined_tags
  freeform_tags         = var.freeform_tags
}

module "policies" {
  source = "../../../modules/iam/policies"

  providers = {
    oci = oci.home
  }

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.parent_compartment_ocid
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  enable_default_policies = false
  group_names             = module.groups.group_names
  policies                = local.policy_definitions
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}
