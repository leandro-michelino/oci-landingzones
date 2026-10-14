# Last successful validation: 2026-10-13 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Scope: schema validation only; full live lifecycle not verified.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
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
  child_compartments           = local.child_compartments
  enable_delete                = var.enable_delete
  defined_tags                 = var.defined_tags
  freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
      Workload  = local.workload_name
    }
  )
}

# Last successful validation: 2026-10-13 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Scope: schema validation only; full live lifecycle not verified.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
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

# Last successful validation: 2026-10-13 | blueprint Terraform init/validate | oracle/oci 9.9.0.
# Scope: schema validation only; full live lifecycle not verified.
# Evidence: docs/EPHEMERAL-DEPLOYMENT-EVIDENCE.md; module call validated in this blueprint context.
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
  compartment_names       = module.compartments.compartment_names
  policies                = local.policy_definitions
  defined_tags            = var.defined_tags
  freeform_tags           = var.freeform_tags
}
