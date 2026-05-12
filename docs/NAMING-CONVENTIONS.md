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
| Network Firewall | `nfw` |
| IAM Group | `grp` |
| IAM Policy | `pol` |
| Dynamic Group | `dg` |
| Identity Domain | `idd` |
| Tag Namespace | `tns` |
| Budget | `bgt` |
| Vault | `vlt` |
| Encryption Key | `key` |
| Bucket | `bkt` |
| Bastion | `bas` |
| Log Group | `lg` |
| Alarm | `alm` |
| Notification Topic | `top` |
| OKE Cluster | `oke` |
| Compute Instance | `inst` |
| Instance Pool | `ip` |
| Load Balancer | `lb` |
| API Gateway | `apigw` |
| CPE | `cpe` |
| IPSec Connection | `vpn` |
| FastConnect Circuit | `fc` |
| ZPR Namespace | `zpr` |

## Examples

```text
acme-prod-fra-cmp-network
acme-prod-fra-grp-network-admins
acme-prod-fra-vcn-hub
acme-prod-fra-sn-hub-dmz
acme-prod-fra-drg
acme-prod-fra-nfw-hub
acme-prod-fra-cmp-oe-finance
```
