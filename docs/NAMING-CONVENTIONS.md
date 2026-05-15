# OCI Naming Conventions

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Format

```text
<org>-<env>-<region-key>-<resource-type>[-<description>[-<index>]]
```

Rules:

- Use lowercase names.
- Use hyphens as delimiters.
- Do not use underscores.
- Keep names below 100 characters.
- Prefer stable semantic descriptions over implementation details.

Terraform code uses `local.name_prefix` for the shared OCI prefix only:

```hcl
name_prefix = "${var.org}-${var.environment}-${var.region_key}"
```

Blueprint or service scope belongs after the resource-type segment, not inside
`local.name_prefix`. For example, use `acme-prod-fra-bkt-agents-source`, not
`acme-prod-fra-agents-source`.

## Segments

| Segment | Example | Notes |
|---|---|---|
| `org` | `acme` | Short organization prefix. |
| `env` | `prod` | `dev`, `uat`, `prod`, `nonprod`, or `dr`. |
| `region-key` | `fra` | Short OCI region code. |
| `resource-type` | `vcn` | Abbreviation from the resource type table. |
| `description` | `hub` | Optional workload, role, or tier label. |
| `index` | `01` | Optional two-digit sequence. |

## Region Keys

| OCI Region | Key |
|---|---|
| `eu-frankfurt-1` | `fra` |
| `uk-london-1` | `lhr` |
| `af-johannesburg-1` | `jnb` |
| `sa-saopaulo-1` | `gru` |
| `eu-amsterdam-1` | `ams` |
| `us-ashburn-1` | `iad` |
| `us-phoenix-1` | `phx` |
| `me-dubai-1` | `dxb` |
| `eu-madrid-1` | `mad` |
| `ap-sydney-1` | `syd` |
| `ap-tokyo-1` | `nrt` |

## Resource Type Abbreviations

| Resource | Abbreviation |
|---|---|
| Compartment | `cmp` |
| VCN | `vcn` |
| Subnet | `sn` |
| Network Security Group | `nsg` |
| Security List | `sl` |
| Dynamic Routing Gateway | `drg` |
| DRG Attachment | `drga` |
| Internet Gateway | `igw` |
| NAT Gateway | `nat` |
| Service Gateway | `sgw` |
| Route Table | `rt` |
| VNIC | `vnic` |
| Backend Set | `bset` |
| Listener | `lis` |
| Network Firewall | `nfw` |
| Network Firewall Policy | `nfwpol` |
| Network Load Balancer | `nlb` |
| Network Appliance | `nva` |
| IAM Group | `grp` |
| IAM Policy | `pol` |
| Dynamic Group | `dgrp` |
| Identity Domain | `idd` |
| Tag Namespace | `tns` |
| Budget | `bgt` |
| Budget Alert Rule | `bgtal` |
| Vault | `vlt` |
| Encryption Key | `key` |
| Bucket | `bkt` |
| Secret | `sec` |
| Bastion | `bst` |
| Log Group | `lg` |
| Log | `log` |
| Saved Search | `log-search` |
| Alarm | `alm` |
| Notification Topic | `top` |
| OKE Cluster | `oke` |
| Node Pool | `np` |
| Oracle Function | `fn` |
| Function Application | `app` |
| Container Instance | `ci` |
| Container Repository | `repo` |
| Compute Instance | `inst` |
| Instance Pool | `ip` |
| Load Balancer | `lb` |
| API Gateway | `apigw` |
| API Gateway Deployment | `apidep` |
| CPE | `cpe` |
| IPSec Connection | `vpn` |
| FastConnect Circuit | `fc` |
| ZPR Namespace | `zpr` |
| Event Rule | `evt` |
| Service Connector | `sch` |
| Stream | `stream` |
| Stream Pool | `streampool` |
| DevOps Repository | `repo` |
| DevOps Project | `proj` |
| DevOps Build Pipeline | `build` |
| DevOps Deploy Pipeline | `deploy` |
| Private Endpoint | `pe` |
| AI Project | `aip` |
| AI Cluster | `cluster` |
| AI Model | `model` |
| GenAI Agent | `agent` |
| GenAI Knowledge Base | `kb` |
| GenAI Endpoint | `ep` |
| GenAI Data Source | `ds` |
| GenAI Job | `job` |
| GenAI Tool | `tool` |
| Oracle Analytics Cloud | `oac` |
| Oracle Integration Cloud | `oic` |
| Private Access Channel | `pac` |
| Autonomous Database | `adb` |
| Database System | `db` |
| Redis Cluster | `redis` |
| Exadata Infrastructure | `exa` |
| Data Safe Target | `dst` |
| Cloud Guard | `cg` |
| Security Zone | `sz` |
| Vulnerability Scanning | `vss` |
| Optimizer | `opt` |
| Workload | `wl` |

## Examples

```text
acme-prod-fra-cmp-network
acme-prod-fra-grp-network-admins
acme-prod-fra-vcn-hub
acme-prod-fra-sn-hub-dmz
acme-prod-fra-drg
acme-prod-fra-nfw-hub
acme-prod-fra-cmp-oe-finance
acme-prod-fra-bkt-agents-source
acme-prod-mad-fn-payments-01
```

## Validation

Run the naming guard before committing broad blueprint changes:

```bash
./scripts/check-naming-conventions.sh
```

The repository contract check also runs this guard through
`./scripts/check-repo-contracts.sh`.
