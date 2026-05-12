# Governance Modules

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This directory groups reusable modules for landing-zone governance controls.
The folder does not deploy resources by itself; use the modules from a
blueprint such as `blueprints/core/`.

## Modules

- `tagging/` - namespace, tag, and tag-default foundations.
- `logging/` - audit and service logging foundations.
- `budgets/` - budget and alert-rule controls.
- `events/` - event rules and notification wiring.

## Usage Notes

- Establish tagging before policies or budgets that rely on ownership metadata.
- Keep cost and notification targets explicit per environment.
- Review each child module README for inputs, outputs, and opt-in behavior.
