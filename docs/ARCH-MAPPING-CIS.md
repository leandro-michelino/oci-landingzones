# CIS OCI Benchmark Mapping

This document maps target landing zone capabilities to CIS OCI Benchmark
requirements. The mapping starts as an implementation guide and should become a
traceability record as modules are added.

The generic landing zone blueprints do not enable CIS behavior by default. Use
the dedicated CIS landing zone folders when a CIS profile is required:

- `blueprints/cis/level1/`: baseline CIS-aligned landing zone controls.
- `blueprints/cis/level2/`: stricter profile for regulated or high-security
  environments.

| CIS Section | Requirement | Module | Blueprint | Applies To | Priority | Status |
|---|---|---|---|---|---|---|
| 1.1 | Avoid root compartment usage | `iam/compartments` | `core` | Level 1, Level 2 | P0 | Implemented |
| 1.2 | Local service admin account | `iam/groups`, `iam/policies` | `core` | Level 1, Level 2 | P0 | Partial |
| 1.3 | MFA enforced | `iam/policies` | `core` | Level 1, Level 2 | P0 | Planned |
| 1.7 | API keys rotated before 90 days | `governance/events` | `core` | Level 1, Level 2 | P1 | Planned |
| 1.13 | No API keys on root user | `iam/policies` | `core` | Level 1, Level 2 | P0 | Planned |
| 1.15 | Break-glass account MFA | `iam/groups`, IdP integration | `identity/cis-basic` | Level 1, Level 2 | P0 | Planned |
| 2.1 | No broad ingress except approved DMZ patterns | `networking/*` | Networking blueprints | Level 1, Level 2 | P0 | Planned |
| 2.2 | SSH not open to the internet | `networking/*/nsg` | Networking blueprints | Level 1, Level 2 | P0 | Planned |
| 2.5 | Default security list blocks SSH/RDP | `networking/*` | Networking blueprints | Level 1, Level 2 | P0 | Planned |
| 3.1 | Audit log retention configured | `governance/logging` | `core` | Level 1, Level 2 | P0 | Planned |
| 3.2 | Object Storage write logs enabled | `governance/logging` | `core` | Level 1, Level 2 | P1 | Planned |
| 3.3-3.6 | VCN flow logs enabled | `governance/logging` | Networking blueprints | Level 1, Level 2 | P1 | Planned |
| 3.7 | Load balancer access logs enabled | `governance/logging` | Networking blueprints | Level 1, Level 2 | P1 | Planned |
| 3.14 | Cloud Guard enabled | `security/cloud-guard` | `core` | Level 1, Level 2 | P0 | Planned |
| 3.17 | Vault with customer-managed keys | `security/vault` | `core` | Level 1, Level 2 | P1 | Planned |
| 4.1 | Object Storage buckets not public | `iam/policies` | `core` | Level 1, Level 2 | P0 | Planned |
| 4.2 | Pre-authenticated request audit alarms | `governance/events` | `core` | Level 1, Level 2 | P1 | Planned |
| 5.1 | Host scanning enabled | `security/vss` | `core` | Level 1, Level 2 | P1 | Planned |
| 5.2 | Container image scanning enabled | `security/vss` | `extensions/oke` | Level 1, Level 2 | P2 | Planned |
