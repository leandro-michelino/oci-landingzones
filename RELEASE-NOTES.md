# Release Notes

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## v0.2.1 - 2026-05-13

### Changed

- Replaced every deployment-local `architecture/README.md` with a real
  deployment-specific ASCII architecture that shows the OCI components,
  dependency order, traffic flow, trust boundaries, Terraform components, and
  Terraform + Ansible output shape for that exact blueprint.
- Removed the previous generic file-contract architecture narrative from the
  architecture folders so each folder now documents what its deployment
  actually builds or references.

## v0.2.0 - 2026-05-13

### Added

- Release `v0.2.0` source references across deployable blueprints and
  release-facing documentation so single-folder and sparse-checkout users fetch
  the current repository release.
- Blueprint-local Ansible `plan.yml`, `apply.yml`, and `destroy.yml` runners
  for every deployable architecture folder.
- Full Terraform resource implementation wiring for identity, compliance,
  disaster recovery, private data platform, telco cloud-native, and remaining
  service extension blueprints that were previously lighter documentation
  shapes.
- OCI OS Management Hub module resources for managed instance groups and
  scheduled jobs.
- Detailed, deployment-specific ASCII architecture pages for every blueprint,
  including Terraform components, request flow, state/input/output contracts,
  architecture review notes, and review checklists.
- Operator-friendly deployment READMEs for all 37 blueprint folders, including
  At A Glance summaries, input decision tables, output hand-off tables,
  workflow commands, deployment order, review checks, and validation guidance.
- Main README banner and a cleaner user journey for choosing, reviewing,
  validating, and running blueprints.

### Changed

- Simplified the README layout to keep only the main README plus each
  deployment README and each deployment-local `architecture/README.md`.
- Reworked generated architecture documentation into fixed-width ASCII diagrams
  that reflect each folder's actual Terraform and Ansible file contract.
- Updated validation guardrails so every Terraform blueprint must keep its
  deployment README, architecture README, At A Glance sections, ASCII design,
  Terraform components, request flow, review checklist, and Terraform + Ansible
  output sections.
- Expanded the deployment pattern catalog and root README language to make the
  repository easier to scan without losing the engineering details.

### Removed

- Redundant category, module, script, Ansible, and shared architecture README
  files that duplicated the deployment-local documentation.
- Rendered architecture exports and legacy diagram source files that made the
  repository heavier without improving reviewability.

## v0.1.0 - 2026-05-12

### Added

- Initial project README.
- Base repository structure for modules, blueprints, environments, docs, tests,
  and scripts.
- Initial Terraform placeholders for planned modules and blueprints.
- Initial Ansible inventories, playbooks, roles, and local orchestration
  structure.
- Dedicated opt-in CIS Level 1 and Level 2 landing zone blueprint folders.
- CIS Level 1 and Level 2 wrappers wired to the implemented core/IAM
  foundation while remaining opt-in.
- Repository cleanup guidance for generated Terraform state, lock, plan, cache,
  and local test artifacts.
- Phase 1 core implementation for landing zone compartments and governance
  tagging.
- Governance logging implementation for core log groups, optional service logs,
  VCN flow-log shortcuts, saved searches, and opt-in tenancy audit retention.
- Cloud Guard implementation for tenancy configuration, default landing zone
  target, optional detector/responder recipe attachments, and additional
  targets.
- Vault/KMS implementation for opt-in landing zone vaults and master encryption
  keys.
- Security Zones implementation for opt-in landing zone compartment guardrails
  using approved security recipes.
- Vulnerability Scanning Service implementation for opt-in host and container
  scan recipes and targets.
- Governance budgets implementation for opt-in landing zone budgets and budget
  alert rules.
- Governance Events implementation for ONS notification topics, subscriptions,
  default IAM change rules, and custom Events rules.
- Monitoring implementation for opt-in alarms, notification topics, and
  subscriptions.
- Phase 2 IAM foundation implementation for IAM groups, dynamic groups, and
  scoped policies.
- Phase 3 networking foundation implementation for reusable hub VCN, spoke VCN,
  DRG, IPSec VPN, OCI Network Firewall, FastConnect, private DNS, ZPR, Bastion,
  and network virtual appliance modules.
- Phase 4 operating entity implementation for single operating entity,
  multi-operating-entity, and workload vending blueprints using reusable
  compartment, group, and policy modules.
- Phase 5 extension implementation for opt-in OKE, API Gateway, Streaming, WAF,
  and Exadata blueprints with resource creation disabled by default.
- Deployable networking foundations for standalone three-tier, standalone
  private-only, custom standalone, standalone ZPR, brownfield VCN references,
  DRG hub-spoke, IPSec, FastConnect, Bastion, OCI Network Firewall, NVA,
  private DNS, ZPR micro-segmentation, dual-region DR, multicloud, shared
  services, transit NVA HA, and regional prod/nonprod hub blueprints.
- Example tfvars and deployment notes for operating entity onboarding,
  multi-entity onboarding, and workload vending.
- Ansible-backed validation that discovers implemented Terraform blueprints,
  uses a Terraform plugin cache, bounds slow Terraform checks with timeouts, and
  cleans generated Terraform artifacts after validation.
- Standalone-consumable blueprint architecture folders that use pinned Git
  module sources instead of local relative module paths.
- Self-contained deployment README files and local architecture image locations
  across core, CIS, identity, networking, operating entity, and extension
  blueprints.
- Expanded deployment pattern catalog with new compliance, disaster recovery,
  operating entity, networking, data platform, and industry blueprint
  placeholders.
- Project guardrails for ignore rules, pre-commit checks, contribution flow, and
  security handling.
- Initial documentation for naming conventions, deployment flow, CIS mapping,
  variables, architecture diagrams, runbooks, and the core blueprint.

### Changed

- Removed unused `region_key_map` local configuration blocks from modules so
  module locals only keep values currently used by Terraform.
- Reworked the repository validation helper so `scripts/validate-all.sh`
  delegates to Ansible when available, with a shell fallback for minimal local
  environments.
- Broadened Ansible validation discovery across Terraform blueprints, made
  scaffold markers fail validation, and moved generated Terraform artifact
  cleanup into an `always` block.
- Reworked bootstrap so the shell helper delegates to Ansible and the Ansible
  role owns reusable bootstrap checks.
