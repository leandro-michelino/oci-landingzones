# CIS Profiles

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

The generic landing zone blueprints do not enable CIS behavior by default. CIS
behavior is opt-in through dedicated landing zone blueprint folders:

- `blueprints/cis/level1/`
- `blueprints/cis/level2/`

## Supported Values

| Folder | Fixed Profile | Intent |
|---|---|---|
| `blueprints/cis/level1/` | `level1` | Baseline CIS-aligned controls suitable for most enterprise landing zone foundations. |
| `blueprints/cis/level2/` | `level2` | Stricter controls for regulated or high-security environments, with more restrictive defaults and additional monitoring. |

## Design Rules

- No CIS profile is enabled by default.
- CIS behavior must be selected by using the `blueprints/cis/level1/` or
  `blueprints/cis/level2/` folder.
- CIS folders fix their profile internally and expose it through an output named
  `cis_level`.
- CIS blueprints pass the selected profile into the implemented core, IAM,
  governance logging, Cloud Guard, Events, and Budgets foundation and will keep
  passing it to later security and networking controls as those modules mature.
- Documentation must explain behavioral differences before any resource behavior
  changes between profiles.
- Real `terraform apply` tests for either level must use an approved test
  compartment and destroy test resources afterward.

## Planned Profile Differences

| Area | Level 1 | Level 2 |
|---|---|---|
| IAM | Least-privilege groups and root compartment avoidance. | Adds stricter break-glass, API key, and privilege separation defaults. |
| Networking | No broad internet ingress except approved DMZ patterns. | Adds stricter private-only and inspected-egress defaults where applicable. |
| Logging | Audit retention enabled and log groups created; service and network logs attach when source OCIDs are provided. | Extends retention and alert coverage for sensitive events. |
| Security | Cloud Guard enabled with a landing zone target; Vault/KMS and Security Zones are available as opt-in controls when key and recipe decisions are approved. | Uses stricter detector/responder posture and stronger enforcement defaults; VSS and Bastion remain future baseline controls. |
| Governance | Required tags, default governance event topic/rules, and optional budgets when thresholds are supplied. | Adds tighter budget, tag, and drift monitoring expectations. |

## Terraform Examples

```bash
cd blueprints/cis/level1
terraform init -backend=false
terraform validate
```

```bash
cd blueprints/cis/level2
terraform init -backend=false
terraform validate
```
