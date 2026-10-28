terraform {
  required_version = ">= 1.12.0"
  required_providers {
    oci    = { source = "oracle/oci", version = "= 9.11.0" }
    google = { source = "hashicorp/google", version = "= 7.46.2" }
  }
}
