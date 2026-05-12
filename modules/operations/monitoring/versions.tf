# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
terraform {
  required_version = ">= 1.12.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}
