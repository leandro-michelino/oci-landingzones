# CIS OCI Benchmark Mapping

This document maps target landing zone capabilities to CIS OCI Benchmark
requirements. The mapping starts as an implementation guide and should become a
traceability record as modules are added.

| CIS Section | Requirement | Module | Blueprint | Priority | Status |
|---|---|---|---|---|---|
| 1.1 | Avoid root compartment usage | `iam/compartments` | `core` | P0 | Planned |
| 1.2 | Local service admin account | `iam/groups`, `iam/policies` | `core` | P0 | Planned |
| 1.3 | MFA enforced | `iam/policies` | `core` | P0 | Planned |
| 1.7 | API keys rotated before 90 days | `governance/events` | `core` | P1 | Planned |
| 1.13 | No API keys on root user | `iam/policies` | `core` | P0 | Planned |
| 1.15 | Break-glass account MFA | `iam/groups`, IdP integration | `identity/cis-basic` | P0 | Planned |
| 2.1 | No broad ingress except approved DMZ patterns | `networking/*` | Networking blueprints | P0 | Planned |
| 2.2 | SSH not open to the internet | `networking/*/nsg` | Networking blueprints | P0 | Planned |
| 2.5 | Default security list blocks SSH/RDP | `networking/*` | Networking blueprints | P0 | Planned |
| 3.1 | Audit log retention configured | `governance/logging` | `core` | P0 | Planned |
| 3.2 | Object Storage write logs enabled | `governance/logging` | `core` | P1 | Planned |
| 3.3-3.6 | VCN flow logs enabled | `governance/logging` | Networking blueprints | P1 | Planned |
| 3.7 | Load balancer access logs enabled | `governance/logging` | Networking blueprints | P1 | Planned |
| 3.14 | Cloud Guard enabled | `security/cloud-guard` | `core` | P0 | Planned |
| 3.17 | Vault with customer-managed keys | `security/vault` | `core` | P1 | Planned |
| 4.1 | Object Storage buckets not public | `iam/policies` | `core` | P0 | Planned |
| 4.2 | Pre-authenticated request audit alarms | `governance/events` | `core` | P1 | Planned |
| 5.1 | Host scanning enabled | `security/vss` | `core` | P1 | Planned |
| 5.2 | Container image scanning enabled | `security/vss` | `extensions/oke` | P2 | Planned |
