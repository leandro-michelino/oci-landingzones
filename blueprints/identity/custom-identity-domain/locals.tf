# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name          = "identity-custom-identity-domain"
  name_prefix             = "${var.org}-${var.environment}-${var.region_key}"
  target_compartment_ocid = coalesce(var.compartment_ocid, var.tenancy_ocid)

  common_freeform_tags = merge(
    var.freeform_tags,
    {
      Blueprint = local.blueprint_name
    }
  )

  identity_domains = {
    for key, domain in var.identity_domains : key => {
      compartment_ocid          = try(domain.compartment_ocid, null)
      display_name              = try(domain.display_name, null)
      description               = try(domain.description, "Custom landing zone identity domain ${key} managed by Terraform.")
      home_region               = try(domain.home_region, null)
      license_type              = try(domain.license_type, "free")
      admin_email               = try(domain.admin_email, null)
      admin_first_name          = try(domain.admin_first_name, null)
      admin_last_name           = try(domain.admin_last_name, null)
      admin_user_name           = try(domain.admin_user_name, null)
      is_hidden_on_login        = try(domain.is_hidden_on_login, false)
      is_notification_bypassed  = try(domain.is_notification_bypassed, false)
      is_primary_email_required = try(domain.is_primary_email_required, true)
      replica_regions           = try(domain.replica_regions, [])
    }
  }

  identity_domain_replicas = {
    for replica in flatten([
      for domain_key, domain in local.identity_domains : [
        for region in domain.replica_regions : {
          key        = "${domain_key}.${region}"
          domain_key = domain_key
          region     = region
        }
      ]
    ]) : replica.key => replica
  }
}
