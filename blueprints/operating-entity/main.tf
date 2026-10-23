# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema only; no live plan or apply because tenancy-root IAM requires the home region outside the Sao Paulo-only scope.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md.
# Review: Parent compartment must be selected explicitly; no new compartment tree was planned or applied.
module "compartments" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/compartments?ref=v0.2.0"

  providers = {
    oci = oci.home
  }

  tenancy_ocid                 = var.tenancy_ocid
  compartment_ocid             = local.parent_compartment_ocid
  region                       = var.region
  org                          = var.org
  environment                  = var.environment
  region_key                   = var.region_key
  root_compartment_name        = local.root_compartment_name
  root_compartment_description = var.root_compartment_description
  child_compartments           = local.workload_compartments
  enable_delete                = var.enable_delete
  defined_tags                 = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint       = local.blueprint_name
      OperatingEntity = local.entity_name
    }
  )
}

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema only; no live plan or apply because tenancy-root IAM requires the home region outside the Sao Paulo-only scope.
# Evidence: docs/NETWORKING-GOVERNANCE-REVIEW-20261023-71-80.md.
# Review: Groups are tenancy-root IAM resources and require the home region; outside this Sao Paulo-only scope.
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
# Review: Delegated policies depend on the compartment tree and home-region IAM; no live plan or apply.
module "policies" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/policies?ref=v0.2.0"

  providers = {
    oci = oci.home
  }

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = coalesce(var.policy_compartment_ocid, local.parent_compartment_ocid)
  region                  = var.region
  org                     = var.org
  environment             = var.environment
  region_key              = var.region_key
  enable_default_policies = false
  group_names             = module.groups.group_names
  compartment_names       = local.entity_compartment_names
  policies                = local.policy_definitions
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}
