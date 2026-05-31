# Azure vWAN + OCI DRG Transit

This blueprint is the "OCI DRG is the transit brain, Azure vWAN is the Azure
aggregation layer" pattern. It is intentionally practical: build or reuse the
OCI DRG side, describe the Azure vWAN/vHub side, keep IPSec available for early
tests or fallback, and record enough contract metadata that another engineer can
understand the route policy without reverse-engineering the whole deployment.

Use this one when you are designing a shared cross-cloud transit pattern, not
just connecting one app VCN to one Azure VNet. It gives you a clean place to
write down the path preference, DNS assumptions, health probes, failover steps,
and the IDs that operations will need later.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/networking/azure-vwan-oci-drg-transit` |
| Best fit | OCI-primary transit pattern with Azure Virtual WAN and Virtual Hub on the Azure side, IPSec/BGP first for rollout, and Interconnect as default path when enabled in final cutover. |
| Primary OCI resources | Optional VCN/subnet, DRG, DRG attachment, CPE, IPSec connection, and transit alert topic. |
| Azure session | vWAN, vHub, workload VNet, optional VPN Gateway, Local Network Gateway, and IPSec connection. |
| Key outputs | `resource_ids`, `interconnect_contract`, `ipsec_fallback_contract`, `transit_contract`, `dns_contract`, `runbook_contract`. |

## Good Fit

- OCI is the primary routing and transit control point.
- Azure workloads need to aggregate through Azure Virtual WAN and Virtual Hub.
- You want IPSec/BGP available before, beside, or behind private interconnect.
- Network and operations teams need explicit route, DNS, and runbook contracts.
- You are preparing a migration, DR design, or regulated private connectivity
  pattern where "the IDs exist somewhere" is not good enough.

If you already know you need a full OCI hub-spoke network plus Azure vWAN
ExpressRoute, look at `hub-spoke-with-azure-vwan-expressroute`. This blueprint
is more about the transit contract and OCI-primary operating model.

## Common Use Cases

| Use case | Why this blueprint helps |
| --- | --- |
| Azure app, OCI data tier | Azure VNets can reach OCI private services through a governed transit path while OCI DRG remains the route anchor. |
| Migration bridge | Teams can move workloads in phases, keep CIDRs documented, and switch between IPSec-first testing and interconnect mode. |
| DR and recovery drills | The `runbook_contract` captures failover and failback sequence so operations are not relying on memory during an incident. |
| Private cross-cloud backbone | ExpressRoute/FastConnect can become the preferred path, with IPSec kept as a tested backup when enabled. |
| Route and DNS governance | Segment CIDRs, DNS endpoints, probe names, and convergence targets are recorded as outputs for review and automation. |

## What It Builds

OCI side:

- Optional primary VCN, hub subnet, route table, security list, and internet
  gateway for test or starter deployments.
- A new DRG, or reuse of an existing DRG through `existing_drg_id`.
- Optional DRG attachment to the created VCN.
- Optional OCI CPE and IPSec connection for the Azure fallback path.
- Optional OCI Notifications topic for transit operations.

Azure side, through `azure/main.bicep`:

- Azure Virtual WAN and Virtual Hub.
- vHub route table labelled for OCI transit.
- A workload VNet and vHub connection.
- Optional Azure VPN Gateway, Local Network Gateway, and IPSec connection.

Contract outputs:

- `interconnect_contract` for private-circuit intent and required IDs.
- `ipsec_fallback_contract` for tunnel and BGP assumptions.
- `transit_contract` for OCI-primary route policy and segmentation.
- `dns_contract` for resolver and health-probe assumptions.
- `runbook_contract` for operational failover and failback steps.

## How To Think About Modes

`connectivity_mode = "without-interconnect"` is the friendly starting point. It
lets you build the OCI transit shape, deploy Azure vWAN/VPN pieces, and validate
IPSec fallback before the private circuit is ready.

`connectivity_mode = "interconnect"` is the dedicated-circuit mode. Use it only
when you have both `fastconnect_virtual_circuit_id` and
`expressroute_circuit_id`, and when the Azure vWAN/vHub IDs are known. The
blueprint enforces those values so the hand-off does not look more complete than
it really is.

## Inputs You Usually Touch

| Input | Notes |
| --- | --- |
| `compartment_ocid` | Target OCI compartment. If omitted, validation-only runs default to the tenancy OCID. |
| `existing_drg_id` | Reuse a DRG when quota is tight or you must preserve an existing transit hub. |
| `enable_oci_primary_network` | Set to `false` if the VCN/subnet already exist elsewhere. |
| `connectivity_mode` | `without-interconnect` for IPSec-first, `interconnect` for ExpressRoute/FastConnect hand-off. |
| `fastconnect_virtual_circuit_id` | Required only in interconnect mode. |
| `expressroute_circuit_id` | Required only in interconnect mode. |
| `azure_virtual_wan_id`, `azure_virtual_hub_id` | Required for interconnect mode contract tracking. |
| `enable_ipsec_fallback` | Creates OCI CPE/IPSec resources when true. |
| `azure_cpe_public_ip` | Azure VPN public IP used by OCI CPE. Required when IPSec fallback is enabled. |
| `azure_network_cidrs` | Azure prefixes that OCI should route toward the transit path. |
| `transit_segments` | Prod, nonprod, and management route lanes for review and automation. |
| `private_dns_zone_fqdn`, `health_probe_fqdn` | DNS and probe metadata used by the optional DNS contract. |

Start from `terraform.tfvars.example`, then keep real OCIDs, public IPs, shared
keys, and local state out of commits.

## Run It

OCI/Terraform path:

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
```

Repo-standard Ansible wrappers:

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
ansible-playbook -i localhost, ansible/plan.yml
CONFIRM_APPLY=true ansible-playbook -i localhost, ansible/apply.yml
```

Azure vWAN/VPN session:

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
ansible-playbook -i localhost, ansible/azure-plan.yml
CONFIRM_AZURE_APPLY=true ansible-playbook -i localhost, ansible/azure-apply.yml
```

IPSec validation:

```bash
cd blueprints/networking/azure-vwan-oci-drg-transit
export OCI_AZURE_TRANSIT_IPSEC_CONNECTION_ID="ocid1.ipsecconnection.oc1..example"
ansible-playbook -i localhost, ansible/azure-ipsec-verify.yml
```

Optional ping validation from an Azure VM:

```bash
export AZURE_TEST_VM_RESOURCE_GROUP="rg-test"
export AZURE_TEST_VM_NAME="vm-test"
export OCI_PING_TARGET_IP="10.58.10.10"
ansible-playbook -i localhost, ansible/azure-ipsec-verify.yml
```

Cross-cloud Linux VM readiness (recommended for real packet validation):

1. OCI side:
   - Create a small Linux VM in the OCI transit subnet (example: `10.58.10.0/24`).
   - Confirm subnet route table contains Azure CIDRs through DRG.
   - Confirm OCI security list allows at least ICMP and SSH from Azure CIDRs.
2. Azure side:
   - Create a small Linux VM in the Azure workload subnet (example: `10.88.10.0/24`).
   - Confirm workload route table includes OCI CIDR via `VirtualNetworkGateway`.
   - Confirm NSG allows at least ICMP and SSH from OCI CIDRs.
3. Verification:
   - Verify Azure VPN connection state (`Connected`).
   - Verify at least one OCI IPSec tunnel state (`UP`).
   - Run in-guest ping from Azure VM to OCI private IP.
   - Run reverse ping or TCP checks from OCI VM to Azure private IP.

Destroy the Azure side when the test is done:

```bash
CONFIRM_AZURE_DESTROY=true ansible-playbook -i localhost, ansible/azure-destroy.yml
```

Destroy the OCI side only when you are sure the DRG/VCN are not being reused:

```bash
CONFIRM_DESTROY=true ansible-playbook -i localhost, ansible/destroy.yml
```

## What Good Looks Like

- Terraform validates cleanly.
- Azure vWAN and vHub reach `Succeeded`.
- If VPN is enabled, Azure VPN Gateway reaches `Succeeded` and OCI IPSec tunnels
  are available.
- OCI route tables include the Azure CIDRs through the DRG.
- The outputs clearly show the DRG, optional IPSec IDs, Azure vWAN/vHub IDs,
  route segments, DNS assumptions, and runbook steps.

## Field Notes

- For multicloud tests in this repository, use Brazil regions by default:
  OCI `sa-saopaulo-1` and Azure `brazilsouth`.
- Azure vWAN/vHub plus VPN Gateway readiness can be slow. Expect 45 to 60
  minutes in normal cases, and up to 6 hours in constrained windows.
- DRG and IPSec quota can block tests. Use `existing_drg_id` when you need to
  preserve or reuse a known DRG.
- For ExpressRoute/FastConnect tests, pair the Azure peering location with the
  OCI FastConnect region. A private circuit that is technically up but regionally
  mismatched is not a useful validation.
- For `without-interconnect` mode, keep both interconnect IDs unset and drive
  data-plane tests through IPSec path only.

## Folder Map

```text
blueprints/networking/azure-vwan-oci-drg-transit/
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
|-- ansible/
|   |-- plan.yml
|   |-- apply.yml
|   |-- destroy.yml
|   |-- azure-plan.yml
|   |-- azure-apply.yml
|   |-- azure-destroy.yml
|   `-- azure-ipsec-verify.yml
`-- hello-world/index.html
```

## Before You Hand It Over

- Confirm OCI and Azure CIDRs do not overlap.
- Confirm which cloud owns route inspection and where DNS resolution happens.
- Confirm whether IPSec is only a test path, a fallback path, or both.
- Confirm the private-circuit IDs before switching to interconnect mode.
- Capture validation evidence: Azure provisioning states, OCI IPSec/FastConnect
  states, BGP state, and at least one packet test when compute endpoints are
  available.
