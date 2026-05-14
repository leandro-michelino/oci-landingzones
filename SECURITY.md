# Security Policy

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Supported Branch

Security fixes are accepted against the `main` branch while the project is being
bootstrapped.

## Reporting Issues

Do not open public issues for vulnerabilities, exposed credentials, tenancy
identifiers, or customer-specific architecture details. Report them privately to
the repository owner.

## Security Expectations

- Do not commit private keys, OCI config files, state files, plans, or
  `terraform.tfvars`.
- Use least-privilege IAM policies.
- Keep root compartment usage limited to bootstrap and governance boundaries.
- Prefer private subnets for workloads.
- Route spoke egress through the hub for inspection in hub-spoke patterns.
- Use customer-managed keys where a service supports them.
- For image-based runtimes such as Container Instances and Oracle Functions,
  use approved registries, reviewed tags or digests, and private repository
  access unless public image pulls are intentional.
- Keep diagrams and documentation free of customer secrets and real private
  network details unless explicitly approved for the repository.
