# CIS, Compliance, Core, And Database Review, October 14, 2026

## Ten Blueprint Entries

This round continues the item-by-item review after Networking and AI. All real
operations used OCI profile `DEFAULT`, `sa-saopaulo-1`, and the explicitly
selected Leandro.Michelino compartment. Administrative and paid-service scope
were kept separate from the workload-compartment network tests.

| Blueprint | Confirmed Validation | Live Boundary |
| --- | --- | --- |
| `cis/level1` | Isolated init/validate and mocked plan/regressions passed | Mocked only; tenancy administration and security services not changed |
| `cis/level2` | Isolated init/validate and mocked plan/regressions passed | Mocked only; tenancy administration and security services not changed |
| `compliance/healthcare-pci` | Isolated init/validate and mocked plan/regressions passed | Mocked only; tenancy administration and security services not changed |
| `compliance/scca-cloud-native` | Isolated init/validate and mocked plan/regressions passed | Mocked only; tenancy administration and security services not changed |
| `compliance/security-posture` | Isolated init/validate and mocked plan/regressions passed | Mocked only; tenancy administration and security services not changed |
| `compliance/zero-trust` | Isolated init/validate and mocked plan/regressions passed | Mocked only; tenancy administration and security services not changed |
| `core` | Isolated init/validate and mocked plan/regressions passed | Mocked only; tenancy administration and security services not changed |
| `data-platform/apex-adw` | Isolated init/validate and mocked plan/regressions passed | Mocked only; no paid LB/secret or database session |
| `data-platform/autonomous-database` | Isolated init/validate and mocked plan/regressions passed | Private network only; five declared resources created and removed; database/backup disabled |
| `data-platform/mongodb-api` | Isolated init/validate and mocked plan/regressions passed | Private network only; five declared resources created and removed; database/backup disabled |

Cost Optimization also received a dependency follow-up: the published Budget
scope fix and the home-region provider binding, with a separate mocked test.
It is not counted as an additional full workload lifecycle review.

## Errors Corrected And Their Evidence

- The original APEX, Autonomous Database, and MongoDB minimum plans failed on
  `coalesce(null, null)` for absent optional IP, URL, subnet, or endpoint labels.
  Null-safe selections now permit disabled/public-mode plans.
- Budget resources now use tenancy-root ownership while tracking separate
  workload targets. Both default and custom-target regressions pass; the
  original implementation fails those same assertions. The Core and Cost
  Optimization callers bind budgets to the home-region provider.
- Healthcare/PCI IAM policies, budgets, and alerts use the home provider. Data
  Safe registration requires an existing Autonomous Database identifier when
  that database type is selected. No administrative/Data Safe objects were
  created during the live tests.
- Function and Streaming Events actions no longer evaluate an unrelated ONS
  topic. Tests exercise both action types without creating a topic. The legacy
  Events `actions` syntax is retained for provider compatibility and emits a
  deprecation warning under 9.9.0; this warning is not a runtime validation.
- The SCCA default plan failed in its old Firewall dependency even with the
  Firewall disabled. Its network pin now selects the published disabled-mode
  fix. Zero Trust selects the published web-tier separation and ZPR scope guard.
- APEX secret creation count uses an explicit boolean instead of sensitive
  content or dependency IDs. Reusing an existing secret requires
  `enable_admin_secret=false`; enabling creation requires Vault/key/content.
- Always Free database inputs reject non-home-region placement, private
  endpoints, and manual backups. This does not validate every free-tier sizing,
  availability, or feature combination, and does not authorize a paid database.
- Autonomous Database adds opt-in client ingress on the configured SQL port;
  default client CIDRs remain empty. Both database network foundations attach
  an explicit empty security list to avoid the VCN default SSH/ICMP rules.
  NSGs provide the configured stateful TCP client rules. SQL/HTTPS/MongoDB
  connectivity, credentials, and running databases remain untested.
- All reviewed providers preserve OCI-managed provenance tags without ignoring
  customer tags. Comments and operator notes remain in English.

The shared fixes were published before selecting their immutable references:
Budget module `80e439cd48a4b6dce4f63e54f53a45a621236601`, then Core
`fffa8dae83ef178236b3187dc4ba7b82ea2a5f84`. CIS and Compliance consumers now
reference that Core revision. No existing release tag was moved.

## Live Network Verification And Cleanup

The final Autonomous Database and MongoDB API fixtures each created a VCN,
private subnet, NSG, empty security list, and one client rule. Per-resource OCI
reads verified compartment ownership, private subnet configuration, the exact
attached empty list, and stateful TCP 1522/27017 rules. The post-apply Terraform
plans reported no differences. Both fixtures were destroyed before continuing;
managed state is empty and each recorded resource was confirmed deleted.

An earlier four-resource network run was also destroyed and verified before the
empty-list correction. This round therefore created and removed 18 declared
network resources across the initial and final tests. Implicit VCN defaults
were checked through final network inventory, including DHCP options.

The final audit returned zero active VCNs, subnets, route tables, security lists,
IGWs, NAT/Service Gateways, NSGs, DHCP options, DRGs, and NLBs in the checked
compartment, with zero test leftovers. No database, backup, LB, Vault secret,
CIS hierarchy, IAM, Budget, Cloud Guard configuration, or ZPR onboarding was
created by the real tests.

## Validation And Scanner Boundaries

- Complete repository init/validate: 80/80 blueprint entries, OCI provider 9.9.0,
  with exact pinned source revisions remapped in isolated fixtures.
- Public mock suite: 35 passed cases in 16 suites, including earlier regressions.
- The ten selected playbook groups: 30/30 Ansible syntax checks passed. The
  earlier full 298-playbook result remains historical evidence; no playbook
  behavior changed in this round.
- TFLint and Trivy passed under repository configuration. Checkov uses the
  original Git source references rather than remapped fixture paths.
- Two resource-scoped `CKV_OCI_16` exceptions explain the intentionally
  ingress-empty security lists: opening an ingress rule to satisfy the scanner
  would undermine the explicit NSG-only model. No global exclusion was added.
  Stateful database rule exceptions remain documented alongside their rules.
- Formatting, repository contracts, local links, staged secret scanning, and
  repository publication hooks are required before the final main push.

## Official References And Remaining Limits

Budget administration and separate targets follow [Oracle budget creation](https://docs.oracle.com/en-us/iaas/Content/Billing/Tasks/create-budget.htm)
and [home-region service guidance](https://www.ateam-oracle.com/oci-home-region-explained-its-role-in-identity-domains-and-service-access).
The network design follows [Oracle's additive security-rule model](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securityrules.htm).
Always Free restrictions follow [Oracle Autonomous Database limits](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/autonomous-always-free.html).
[Audit retention](https://docs.oracle.com/en-us/iaas/Content/Audit/Tasks/settingretentionperiod.htm)
is currently 365 days, and [Cloud Guard reporting-region changes](https://docs.oracle.com/en-us/iaas/Content/cloud-guard/using/settings-change-rpt-region.htm)
require review of the existing tenancy configuration.

A CIS preset, SCCA scaffold, or Healthcare/PCI label does not certify benchmark
coverage, accreditation, or regulatory compliance. Full administrative tests
would change resources outside the selected compartment or region; those remain
pending separate authorization. Databases, paid load balancers, Vault/Secrets,
Data Safe operations, and application sessions require their own inputs and cost
review. No account-wide billing audit was performed.

Private evidence remains in `.leo-local/cis-compliance-data-20261014/`, including
baseline failures, corrected plans, public regression logs, and initial/final
network lifecycle directories. The final directory includes
`final-api-audit.json` and `security-verification.json`. These private records
and deployment artifacts remain outside Git.
