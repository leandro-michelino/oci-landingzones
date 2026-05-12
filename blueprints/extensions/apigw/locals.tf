# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
locals {
  blueprint_name = "extensions-apigw"
  name_prefix    = "${var.org}-${var.environment}-${var.region_key}"
}
