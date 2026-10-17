mock_provider "oci" {}
mock_provider "oci" { alias = "home" }
mock_provider "cloudflare" {}

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
}

run "no_bucket_or_external_resources_by_default" {
  command = plan

  assert {
    condition     = length(oci_objectstorage_bucket.asset) == 0 && length(oci_objectstorage_preauthrequest.this) == 0 && length(oci_dns_rrset.cdn_cname) == 0 && length(cloudflare_dns_record.cdn) == 0 && length(cloudflare_ruleset.cache_static_assets) == 0
    error_message = "CDN defaults must not create an OCI bucket, PAR, DNS, or Cloudflare resources."
  }
}
