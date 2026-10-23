# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema only; no live plan or apply because tenancy-root IAM requires the home region outside the Sao Paulo-only scope.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md.
# Review: Each entity creates a child tree under the selected parent; no live plan or apply.
module "entity_compartments" {
  source   = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/compartments?ref=v0.2.0"
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

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema only; no live plan or apply because tenancy-root IAM requires the home region outside the Sao Paulo-only scope.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md.
# Review: Per-entity groups are tenancy-root IAM resources in the home region; outside this scope.
module "groups" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/groups?ref=v0.2.0"

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

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema only; no live plan or apply because tenancy-root IAM requires the home region outside the Sao Paulo-only scope.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md.
# Review: Per-entity policies depend on created groups and compartments; no live plan or apply.
module "policies" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/policies?ref=v0.2.0"

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
