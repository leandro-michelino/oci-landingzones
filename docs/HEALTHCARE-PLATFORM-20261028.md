# Healthcare Platform Local Validation / 2026-10-28

Scope: `blueprints/industry/healthcare-platform`, oracle/oci 9.11.0.

- Terraform init with backend disabled: passed.
- Terraform validate: passed.
- Ten mocked plan regressions: passed, zero failures.
- No live plan, apply, API inventory, provisioning, guest/app behavior, TLS handshake, data access or restore test.

The tests cover disabled defaults, private network/flow-log configuration, OSN-only
routing, cost and foundation gates, KMS prerequisites, overlapping subnet and
Internet-wide client-prefix rejection, encrypted data services and private
application/TLS/backup configuration. Dummy certificates, IDs and passwords are
mock-only fixtures and cannot be used as deployment evidence.

Evidence is reproducible with the checked-in `tests/configuration-regressions.tftest.hcl`.
Provider schema validation and mocked plans do not prove regional capacity,
KMS permissions, hospital connectivity, application functionality, data protection
outcomes or compliance. No cloud resources were created; no cleanup lifecycle was required.

Diagram delivery: 21 OCI resource declarations plus one local guard declaration;
three resource-detail pages, one existing-resource input page and one overview.
All five PNGs were rendered with draw.io and inspected. Nineteen overview
relationships are registered with reviewed source/target/arrow/path semantics.
The source inventory retains full creation expressions and five identifier-input
references; nested image/AD configuration is described in the application contract.

Ansible plan/apply/destroy syntax checks passed; no playbook actions were executed.
