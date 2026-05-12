# Security Modules

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This directory groups reusable modules for OCI security foundations. The folder
does not deploy resources by itself; use the modules from a blueprint such as
`blueprints/core/` or the CIS wrapper blueprints.

## Modules

- `cloud-guard/` - Cloud Guard target and detector/responder controls.
- `security-zones/` - Security Zone recipe and zone foundations.
- `vault/` - Vault and customer-managed key foundations.
- `vss/` - Vulnerability Scanning Service targets and recipes.
- `bastion/` - Bastion service foundations.

## Usage Notes

- Security controls are ownership-sensitive and usually opt-in unless a CIS blueprint enables them.
- Keep key, bastion, scanning, and Cloud Guard scope decisions explicit per environment.
- Review each child module README for inputs, outputs, and opt-in behavior.
