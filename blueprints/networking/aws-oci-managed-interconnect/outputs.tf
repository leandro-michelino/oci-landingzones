output "blueprint_name" { value = local.blueprint_name }
output "name_prefix" { value = local.name_prefix }
output "resource_ids" {
  value = {
    oci_vcn             = try(oci_core_vcn.this[0].id, null)
    oci_subnet          = try(oci_core_subnet.this[0].id, null)
    oci_drg             = try(oci_core_drg.this[0].id, null)
    aws_vpc             = try(aws_vpc.this[0].id, null)
    aws_subnet          = try(aws_subnet.this[0].id, null)
    aws_vgw             = try(aws_vpn_gateway.this[0].id, null)
    aws_dx_gateway      = try(aws_dx_gateway.this[0].id, null)
    aws_security_group  = try(aws_security_group.this[0].id, null)
    oci_virtual_circuit = try(oci_core_virtual_circuit.this[0].id, null)
  }
}
