# Operations Modules

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This directory groups reusable modules for operational visibility and lifecycle
management. The folder does not deploy resources by itself; use the modules
from a blueprint that owns the target compartment and notification model.

## Modules

- `monitoring/` - alarms and metric-based operational controls.
- `os-management/` - operating-system management foundations.

## Usage Notes

- Wire alarms to environment-owned notification topics or event workflows.
- Keep OS management opt-in until target fleet ownership and maintenance windows are clear.
- Review each child module README for inputs, outputs, and opt-in behavior.
