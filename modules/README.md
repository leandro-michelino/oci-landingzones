# Terraform Modules

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This directory contains reusable OCI Terraform modules composed by the
blueprints under `blueprints/`. The category folders are organizational only;
deployments should start from a blueprint entry point rather than from this
directory.

## Module Families

- `iam/` - compartments, groups, dynamic groups, and scoped policies.
- `governance/` - tagging, logging, budgets, and event rules.
- `security/` - Cloud Guard, Security Zones, Vault/KMS, VSS, and Bastion.
- `networking/` - VCN, DRG, DNS, VPN, FastConnect, firewall, appliance, and ZPR building blocks.
- `operations/` - monitoring and operating-system management foundations.

## Usage Notes

- Module defaults are intentionally conservative; high-cost, externally managed, or ownership-sensitive resources are disabled unless a blueprint opts in.
- Keep resource orchestration, provider configuration, and environment-specific values in blueprints.
- Add or update the nearest module README whenever module inputs, outputs, or behavior change.
