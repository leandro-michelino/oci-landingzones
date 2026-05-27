# Hub-Spoke With Azure vWAN ExpressRoute

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this page as the operator guide for
`blueprints/networking/hub-spoke-with-azure-vwan-expressroute`. It builds an OCI
hub-spoke network, attaches the OCI hub DRG to FastConnect, and provides an Azure
session for Virtual WAN, Virtual Hub, ExpressRoute Gateway, and VNet connections.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/hub-spoke-with-azure-vwan-expressroute` |
| Best fit | OCI hub-spoke network connected to Azure Virtual WAN through ExpressRoute Gateway, with Azure VNets mapped to OCI spoke VCNs. |
| Terraform shape | `network`, `fastconnect`, `ipsec_vpn`, `terraform_data.azure_vwan_contract` |
| Azure shape | `azure/main.bicep` creates vWAN, vHub, vHub route table, ExpressRoute Gateway, VNet connections, VNets, subnets, and NSGs. |
| Inputs to settle first | `hub_vcn_cidr_block`, `spoke_vcns`, `customer_bgp_asn`, `provider_service_id`, `provider_service_key_name`, `cross_connect_mappings`, `expressroute_circuit_id`, `expressroute_circuit_peering_id`, `azure_vnet_peerings` |
| Outputs to hand off | `hub_vcn_id`, `drg_id`, `spoke_vcn_ids`, `virtual_circuit_id`, `azure_vwan_contract`, `spoke_vnet_peering_contract` |
| Local runner | `terraform plan` for OCI; `ansible/azure-plan.yml` for Azure what-if. |

## Deployment Purpose

This deployment makes Azure vWAN explicit instead of hiding it inside the generic
multicloud interconnect blueprint. OCI remains the hub-spoke owner, while Azure
Virtual WAN and Virtual Hub provide the Azure transit domain for connected VNets.

## When To Use This Deployment

- OCI hub and spoke VCNs must exchange private routes with Azure VNets.
- The primary path is Azure ExpressRoute Gateway to OCI FastConnect.
- Azure VNets should connect to a Virtual Hub rather than direct VNet peering.
- IPSec is useful as an optional backup path or early test path.

## What This Deploys

| Kind | Name | Source Or Role |
| --- | --- | --- |
| Module | `network` | `blueprints/networking/hub-spoke-with-drg-and-three-tier-vcns @ v0.2.0` |
| Module | `fastconnect` | `modules/networking/fastconnect @ v0.2.0` |
| Module | `ipsec_vpn` | `modules/networking/ipsec-vpn @ v0.2.0` |
| Resource | `terraform_data.azure_vwan_contract` | OCI to Azure vWAN routing and peering hand-off contract. |
| Azure template | `azure/main.bicep` | Azure vWAN, vHub, ExpressRoute Gateway, VNets, and vHub VNet connections. |

## Folder Contract

```text
blueprints/networking/hub-spoke-with-azure-vwan-expressroute/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- providers.tf
|-- versions.tf
|-- terraform.tfvars.example
|-- azure/
|   |-- README.md
|   |-- main.bicep
|   `-- parameters.example.json
`-- ansible/
    |-- plan.yml
    |-- apply.yml
    |-- destroy.yml
    |-- azure-plan.yml
    |-- azure-apply.yml
    `-- azure-destroy.yml
```

## Inputs To Decide

Start from `terraform.tfvars.example`, then create a local ignored `terraform.tfvars`
with real OCIDs, CIDRs, ExpressRoute IDs, and provider details.

| Input | What To Decide |
| --- | --- |
| `hub_vcn_cidr_block`, `hub_subnets` | OCI hub address space and subnet roles. |
| `spoke_vcns`, `spoke_route_tables`, `spoke_security_lists` | OCI spoke address spaces, subnets, route behavior, and security controls. |
| `enable_fastconnect`, `customer_bgp_asn`, `provider_service_id`, `provider_service_key_name`, `cross_connect_mappings` | OCI FastConnect creation and partner hand-off details. Keep disabled until real provider values are known. |
| `expressroute_circuit_id`, `expressroute_circuit_peering_id` | Azure ExpressRoute circuit and private peering IDs. |
| `azure_virtual_wan_id`, `azure_virtual_hub_id`, `azure_expressroute_gateway_id` | Azure IDs copied from the Azure session or existing resources. |
| `azure_vnet_peerings` | Azure VNets connected to the Virtual Hub and mapped to OCI spoke keys. |
| `enable_ipsec`, `cpe_ip_address`, `remote_cloud_cidr_blocks` | Optional backup or test VPN path. |

## Terraform And Azure Workflow

OCI side:

```bash
cd blueprints/networking/hub-spoke-with-azure-vwan-expressroute
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Azure side:

```bash
cd blueprints/networking/hub-spoke-with-azure-vwan-expressroute
ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
```

After Azure apply, copy the Azure output IDs into local Terraform variables and
run the OCI plan again so `azure_vwan_contract` reflects the final cross-cloud path.

## Review Before Apply

- Confirm OCI hub and spoke CIDRs do not overlap Azure VNet CIDRs.
- Confirm ExpressRoute private peering and OCI FastConnect provider details refer to the same private interconnect path.
- Confirm Azure vHub route table labels and VNet connection names match the intended route domain.
- Keep ExpressRoute authorization keys, provider service keys, state files, and local tfvars out of commits.
- Confirm the architecture file still matches `main.tf`, `variables.tf`, `outputs.tf`, and `azure/main.bicep`.

## Validation

For Azure/OCI interconnect tests, match the Azure ExpressRoute peering location
to the OCI FastConnect region. The latest live validation used:

- Azure ExpressRoute: `brazilsouth` resources, Campinas peering location,
  Oracle Cloud FastConnect provider, `Local_UnlimitedData`, `1 Gbps`.
- OCI FastConnect: `sa-vinhedo-1`, Microsoft Azure provider service, `1 Gbps`,
  target compartment `Leandro_Michelino`.
- Configure Azure Private Peering with peer ASN `31898`, no MD5 shared key for
  this provider-key VC flow, and use the `cross_connect_mappings` returned by
  OCI. The Vinhedo/Campinas validation used VLAN `33`, primary pair
  `10.255.0.1/30` and `10.255.0.2/30`, and secondary pair `10.255.0.5/30` and
  `10.255.0.6/30`.
- Bring the Azure vWAN ExpressRoute Gateway to `Succeeded`, connect it to the
  circuit peering, then check OCI `bgp-session-state` before packet tests. The
  2026-05-27 Vinhedo/Campinas control-plane test reached OCI FastConnect
  `PROVISIONED`, provider `ACTIVE`, BGP `UP`, and one Azure ER gateway
  connection.
- Packet tests require temporary compute endpoints on both sides. If compute
  launch is blocked by tenancy policy or CLI/runtime errors, record the
  control-plane result and rerun packet tests after endpoint creation is fixed.
- Keep IPSec as a separate secondary path. The vWAN ExpressRoute session does
  not create an Azure VPN Gateway, so IPSec requires a separate VPN deployment
  and tunnel parameter exchange.

From the repository root:

```bash
./scripts/validate-all.sh
```
