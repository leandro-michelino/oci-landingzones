terraform {
  required_version = ">= 1.12.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "= 9.11.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.70.0"
    }
  }
}
