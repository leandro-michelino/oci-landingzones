mock_provider "oci" {}
mock_provider "oci" { alias = "home" }

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

run "no_waf_by_default" {
  command = plan

  assert {
    condition     = length(oci_waf_web_app_firewall_policy.this) == 0 && length(oci_waf_web_app_firewall.this) == 0
    error_message = "WAF resources must remain disabled by default."
  }
}

run "reject_attachment_without_load_balancer" {
  command = plan
  variables {
    enable_web_app_firewall = true
    waf_policy_id           = "ocid1.webappfirewallpolicy.oc1.sa-saopaulo-1.example"
  }
  expect_failures = [oci_waf_web_app_firewall.this]
}

run "reject_attachment_without_policy" {
  command = plan
  variables {
    enable_web_app_firewall = true
    load_balancer_id        = "ocid1.loadbalancer.oc1.sa-saopaulo-1.example"
  }
  expect_failures = [oci_waf_web_app_firewall.this]
}

run "use_existing_waf_policy" {
  command = plan
  variables {
    enable_web_app_firewall = true
    load_balancer_id        = "ocid1.loadbalancer.oc1.sa-saopaulo-1.example"
    waf_policy_id           = "ocid1.webappfirewallpolicy.oc1.sa-saopaulo-1.example"
  }

  assert {
    condition     = length(oci_waf_web_app_firewall_policy.this) == 0 && oci_waf_web_app_firewall.this[0].web_app_firewall_policy_id == var.waf_policy_id
    error_message = "An existing WAF policy must be used without creating a second policy."
  }
}
