# IAM Modules

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This directory groups reusable modules for OCI identity and access foundations.
The folder does not deploy resources by itself; use the modules from a
blueprint such as `blueprints/core/` or the CIS wrapper blueprints.

## Modules

- `compartments/` - landing-zone compartment hierarchy.
- `groups/` - human operator and administration groups.
- `dynamic-groups/` - instance, function, and service-principal matching rules.
- `policies/` - scoped tenancy and compartment policy statements.

## Usage Notes

- Create compartments and groups before policies that reference them.
- Keep policy statements scoped to the smallest practical compartment or service boundary.
- Review each child module README for inputs, outputs, and opt-in behavior.
