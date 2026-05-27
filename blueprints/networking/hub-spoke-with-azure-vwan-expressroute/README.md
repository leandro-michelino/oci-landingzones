# Hub-Spoke With Azure vWAN ExpressRoute

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint builds the more concrete version of the OCI plus Azure vWAN
story: OCI hub and spoke VCNs on one side, Azure Virtual WAN and Virtual Hub on
the other, with Azure ExpressRoute Gateway connected to OCI FastConnect.

The goal is simple: let OCI spokes and Azure VNets exchange private routes
through a clean transit design, while leaving enough metadata in Terraform
outputs that operators know exactly which VCNs, VNets, gateways, and circuits
belong together.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/hub-spoke-with-azure-vwan-expressroute` |
| Best fit | OCI hub-spoke network connected to Azure Virtual WAN through ExpressRoute Gateway, with Azure VNets mapped to OCI spoke VCNs. |
| OCI shape | Hub VCN, spoke VCNs, DRG, optional FastConnect, optional IPSec, and route hand-off contracts. |
| Azure session | vWAN, vHub, ExpressRoute Gateway, optional ER connection, Azure VNets, subnets, NSGs, and vHub connections. |
| Key outputs | `hub_vcn_id`, `drg_id`, `spoke_vcn_ids`, `virtual_circuit_id`, `azure_vwan_contract`, `spoke_vnet_peering_contract`. |

## Good Fit

- You need an OCI hub-spoke landing zone connected to Azure VNets.
- Azure VNets should attach to a Virtual Hub rather than many direct peerings.
- ExpressRoute plus FastConnect is the primary private path.
- You want the Azure-side deployment kept next to the OCI blueprint.
- You need a repeatable lab or customer demo for cross-cloud private routing.

If you only need an OCI-primary transit contract with optional IPSec fallback,
use `azure-vwan-oci-drg-transit`. This blueprint is better when you want the
actual OCI hub-spoke topology and Azure vWAN ExpressRoute session together.

## Common Use Cases

| Use case | Why this blueprint helps |
| --- | --- |
| Enterprise app split across clouds | OCI app/database tiers and Azure services can communicate over a private routed path. |
| Azure subscriptions as spokes | Azure VNets connect to vWAN while OCI keeps a hub-spoke VCN model with DRG transit. |
| FastConnect/ExpressRoute validation | The blueprint carries the provider-key hand-off, BGP mappings, Azure gateway connection, and cleanup workflow. |
| Migration runway | Teams can move services between OCI and Azure without redesigning routing every sprint. |
| Customer demo or proof of concept | Creates enough real infrastructure to validate control-plane and, when VMs are available, packet flow. |

## What It Builds

OCI side:

- Hub VCN, hub subnets, spoke VCNs, spoke subnets, route tables, and security
  lists through the hub-spoke module.
- DRG and DRG attachments for the hub/spoke routing domain.
- Optional FastConnect virtual circuit for Azure ExpressRoute.
- Optional IPSec connection for a separate backup or early test path.
- `azure_vwan_contract` and `spoke_vnet_peering_contract` outputs for hand-off.

Azure side, through `azure/main.bicep`:

- Azure Virtual WAN and Virtual Hub.
- vHub route table labelled for OCI transit.
- Optional ExpressRoute Gateway and ExpressRoute Gateway connection.
- One or more Azure VNets, subnets, NSGs, and vHub VNet connections.

## How The Pieces Fit

```text
OCI spoke VCNs
      |
OCI hub VCN
      |
OCI DRG
      |
OCI FastConnect  <->  Azure ExpressRoute
                         |
                    Azure ER Gateway
                         |
                    Azure Virtual Hub
                         |
                    Azure VNets
```

In normal operation, ExpressRoute/FastConnect is the path you care about. IPSec
is intentionally separate here; the Azure vWAN ExpressRoute deployment does not
create an Azure VPN Gateway. If you want IPSec, deploy the VPN path separately
and exchange tunnel parameters with OCI.

## Inputs You Usually Touch

| Input | Notes |
| --- | --- |
| `hub_vcn_cidr_block`, `hub_subnets` | OCI hub address plan. Keep it non-overlapping with Azure. |
| `spoke_vcns` | OCI spoke VCNs and subnets. These are advertised toward Azure. |
| `enable_fastconnect` | Leave false until the Azure circuit and provider values are ready. |
| `customer_bgp_asn` | Azure private peering ASN for the provider-key flow. |
| `provider_service_id` | OCI FastConnect provider service OCID for Microsoft Azure. |
| `provider_service_key_name` | Azure ExpressRoute service key used by OCI FastConnect. |
| `cross_connect_mappings` | BGP/VLAN values returned by OCI and aligned with Azure Private Peering. |
| `expressroute_circuit_id` | Azure ExpressRoute circuit ID for contract tracking. |
| `expressroute_circuit_peering_id` | Azure private peering ID used by the ER gateway connection. |
| `azure_vnet_peerings` | Maps Azure VNets to OCI spoke keys. |
| `enable_route_contract_validation` | Keep false during early planning; enable when IDs and peerings are final. |

Start from `terraform.tfvars.example`. Real service keys, OCIDs, local state,
and generated plan files should stay local.

## Run It

OCI side:

```bash
cd blueprints/networking/hub-spoke-with-azure-vwan-expressroute
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Repo-standard Ansible wrappers:

```bash
cd blueprints/networking/hub-spoke-with-azure-vwan-expressroute
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
```

Azure side:

```bash
cd blueprints/networking/hub-spoke-with-azure-vwan-expressroute
ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
```

After Azure apply, copy the Azure output IDs back into `terraform.tfvars`:

- `azure_virtual_wan_id`
- `azure_virtual_hub_id`
- `azure_expressroute_gateway_id`
- `expressroute_circuit_id`
- `expressroute_circuit_peering_id`
- `azure_vnet_peerings`

Then rerun `terraform plan` so the OCI-side contract outputs match the final
Azure path.

Destroy the Azure test side when done:

```bash
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

Destroy OCI only when you really intend to remove the VCN/DRG topology:

```bash
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

## Region Pairing Notes

For ExpressRoute plus FastConnect, match the Azure ExpressRoute peering location
with the OCI FastConnect region. The live 2026-05-27 validation used:

- OCI: `sa-vinhedo-1`
- Azure peering location: Campinas
- Azure resource location: `brazilsouth`
- Bandwidth: `1 Gbps`
- Azure billing model: `Local_UnlimitedData`
- Azure provider: Oracle Cloud FastConnect
- OCI provider: Microsoft Azure

The control-plane result was good: OCI FastConnect reached `PROVISIONED`,
provider state `ACTIVE`, BGP `UP`, and Azure showed one ExpressRoute Gateway
connection.

The packet test still needs a clean compute run. The validation attempt was
blocked by an Azure CLI VM-create runtime error and OCI compute authorization in
the target compartment. In other words: the circuit came up, but do not claim
end-to-end packet success until temporary VMs can be launched on both sides.

## Provider-Key BGP Notes

For the Vinhedo/Campinas validation, Azure Private Peering was aligned to the
OCI-returned values:

| Field | Value |
| --- | --- |
| Peer ASN | `31898` |
| VLAN | `33` |
| Primary pair | `10.255.0.1/30` and `10.255.0.2/30` |
| Secondary pair | `10.255.0.5/30` and `10.255.0.6/30` |
| MD5/shared key | Empty for this provider-key flow |

Those values are examples from the test run, not universal constants. Read the
OCI FastConnect virtual circuit output and put the returned values into
`cross_connect_mappings` and Azure Private Peering.

## What Good Looks Like

- Azure vWAN, vHub, and ExpressRoute Gateway are `Succeeded`.
- OCI FastConnect is `PROVISIONED`.
- OCI provider state is `ACTIVE`.
- OCI BGP session is `UP`.
- Azure ExpressRoute Gateway has the expected connection to the private peering.
- OCI route tables and Azure vHub/VNet route behavior match the intended CIDRs.
- Packet tests pass from Azure to OCI and OCI to Azure using temporary endpoints.

## Folder Map

```text
blueprints/networking/hub-spoke-with-azure-vwan-expressroute/
|-- README.md
|-- architecture/README.md
|-- main.tf
|-- variables.tf
|-- outputs.tf
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

## Before You Hand It Over

- Confirm all OCI and Azure CIDRs are non-overlapping.
- Confirm the Azure peering location matches the OCI FastConnect region.
- Keep service keys, provider keys, tfvars, plan files, and state files out of
  commits.
- Decide whether the OCI VCN/DRG should be preserved after tests.
- Delete cost-generating resources first: ExpressRoute, FastConnect, gateways,
  VPN gateways, NAT gateways, and test VMs.
- Keep the VCN/DRG only when the test plan explicitly says to preserve them.
