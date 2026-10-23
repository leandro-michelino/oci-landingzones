# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema, 1 mocked plan, and DEFAULT home-region no-change plan; no apply.
# Evidence: docs/EXTENSIONS-IDENTITY-REVIEW-20261023.md; module calls validated in this blueprint context.
module "groups" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/groups?ref=v0.2.0"

  tenancy_ocid          = var.tenancy_ocid
  compartment_ocid      = local.target_compartment_ocid
  region                = coalesce(var.home_region, var.region)
  org                   = var.org
  environment           = var.environment
  region_key            = var.region_key
  cis_level             = local.cis_level
  enable_default_groups = var.enable_default_groups
  groups                = var.groups
  defined_tags          = var.defined_tags
  freeform_tags         = local.common_freeform_tags
}

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema and 1 mocked plans; no live service or traffic test.
# Evidence: docs/EXTENSIONS-IDENTITY-REVIEW-20261023.md; module calls validated in this blueprint context.
module "dynamic_groups" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/dynamic-groups?ref=v0.2.0"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = local.target_compartment_ocid
  region           = coalesce(var.home_region, var.region)
  org              = var.org
  environment      = var.environment
  region_key       = var.region_key
  cis_level        = local.cis_level
  dynamic_groups   = var.dynamic_groups
  defined_tags     = var.defined_tags
  freeform_tags    = local.common_freeform_tags
}

# Last successful validation: 2026-10-23 | blueprint Terraform validate | oracle/oci 9.10.0.
# Scope: schema and 1 mocked plans; no live service or traffic test.
# Evidence: docs/EXTENSIONS-IDENTITY-REVIEW-20261023.md; module calls validated in this blueprint context.
module "policies" {
  source = "git::https://github.com/leandro-michelino/oci-landingzones.git//modules/iam/policies?ref=v0.2.0"

  tenancy_ocid            = var.tenancy_ocid
  compartment_ocid        = local.target_compartment_ocid
  region                  = coalesce(var.home_region, var.region)
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
