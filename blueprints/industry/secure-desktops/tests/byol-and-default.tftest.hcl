mock_provider "oci" {}
mock_provider "oci" { alias = "home" }

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  home_region        = "me-abudhabi-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
}

run "default_pool_stays_disabled_with_unset_os" {
  command = plan

  assert {
    condition     = length(oci_desktops_desktop_pool.this) == 0
    error_message = "An unset image OS must not break a disabled-pool plan."
  }
}

run "windows_11_requires_byol_acknowledgement" {
  command = plan

  variables {
    create_desktop_pool      = true
    image_operating_system   = "Windows 11"
    availability_domain      = "AD-1"
    storage_backup_policy_id = "ocid1.volumebackuppolicy.oc1..example"
    image_id                 = "ocid1.image.oc1.sa-saopaulo-1.example"
    image_name               = "windows-11-test"
    subnet_id                = "ocid1.subnet.oc1.sa-saopaulo-1.example"
    vcn_id                   = "ocid1.vcn.oc1.sa-saopaulo-1.example"
  }

  expect_failures = [var.windows_10_11_byol_acknowledged]
}

run "acknowledged_windows_11_sets_byol_tag" {
  command = plan

  variables {
    create_desktop_pool             = true
    image_operating_system          = "Windows 11"
    windows_10_11_byol_acknowledged = true
    availability_domain             = "AD-1"
    storage_backup_policy_id        = "ocid1.volumebackuppolicy.oc1..example"
    image_id                        = "ocid1.image.oc1.sa-saopaulo-1.example"
    image_name                      = "windows-11-test"
    subnet_id                       = "ocid1.subnet.oc1.sa-saopaulo-1.example"
    vcn_id                          = "ocid1.vcn.oc1.sa-saopaulo-1.example"
  }

  assert {
    condition     = oci_desktops_desktop_pool.this[0].freeform_tags["oci:desktops:enable_byol"] == "true"
    error_message = "An acknowledged Windows 11 pool must carry the Secure Desktops BYOL tag."
  }
}
