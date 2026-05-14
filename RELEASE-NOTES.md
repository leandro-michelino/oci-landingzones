# Release Notes

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Unreleased

### Added

- Eight deployable roadmap blueprints: Autonomous Database, OCI Generative AI
  private landing zone, OCI DevOps pipeline, Observability, Oracle Integration
  Cloud, Oracle Analytics Cloud, Healthcare / PCI compliance, and OKE Service
  Mesh.
- Repository-level ASCII architecture index under `docs/architecture/`.
- Text-first implementation roadmap under `docs/ROADMAP.md`.
- Validation contract notes in `tests/README.md`.
- Fast repository contract guard for repeated documentation fragments,
  blueprint file completeness, and blueprint-local Ansible runner wiring.
- Changed-scope validation entry point for focused blueprint, architecture,
  module, and Ansible edits.
- Cost Optimization operations blueprint with cost-tracking tags, optional tag
  defaults, budgets, notifications, optional Monitoring alarms, optional
  Optimizer profiles, and FinOps IAM policy wiring.
- Oracle APEX on Autonomous Database blueprint with ADB metadata lookup,
  optional private load balancer and ORDS backend wiring, optional Vault secret
  hand-off, and APEX/ORDS outputs.
- Oracle Functions extension blueprint with optional image repository,
  Functions application, image-based functions, API Gateway routes, Events
  triggers, IAM policy statements, and a small Python FDK sample.

### Changed

- Enhanced every deployment-local ASCII architecture with a consistent legend,
  control lane, trust boundary, dependency flow, traffic or signal path, review
  focus, and hand-off lane.
- Cleaned stale setup-marker wording from contribution, FSDR, and ZPR
  documentation surfaces so they match the current deployable blueprint state.
- Added a whole-project review runbook flow and ignored local Ansible async
  artifacts.
- Guarded validation against self-invocation by keeping `validate.yml` out of
  the playbook syntax-check loop it executes.
- Made `scripts/validate-all.sh` shell-native by default for Terraform,
  contract checks, optional scanners, and shared/blueprint-local Ansible syntax
  checks so full validation does not depend on a long-running Ansible role
  subprocess.
- Aligned the default Terraform plan artifact with ignore and cleanup rules by
  using `tfplan.tfplan`.
- Normalized remaining composite blueprint module sources to release-pinned Git
  refs so sparse-checkout and single-folder use stay consistent.
- Added validation to block local `../` Terraform module sources in deployable
  blueprints.
- Extended validation cleanup to remove generated plan files and `.DS_Store`
  metadata in both Ansible and shell fallback paths.
- Kept `terraform_tflint` out of the default pre-commit hook set so optional
  scanner availability stays consistent with the validation script.
- Wired shared Terraform environment handling into validation and destroy
  scripts so local and Ansible Terraform commands use the same automation,
  plugin-cache, and guarded TLS compatibility settings.
- Injected the repository Ansible configuration into validation syntax checks
  so blueprint-local runners resolve shared roles consistently.
- Replaced the optional `tfsec` validation path with Trivy config scanning and
  added explicit scanner configs for TFLint, Checkov, Trivy, and Ansible Lint.

### Removed

- Empty test `.gitkeep` placeholders.

## v0.2.1 - 2026-05-13

### Changed

- Replaced every deployment-local `architecture/README.md` with a real
  deployment-specific ASCII architecture that shows the OCI components,
  dependency order, traffic flow, trust boundaries, Terraform components, and
  local Terraform + Ansible workflow for that exact blueprint.
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
  including Terraform components, request flow, architecture review notes, and
  review checklists.
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
  workflow sections.
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
- Repository cleanup guidance for generated state, lock, plan, cache,
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
