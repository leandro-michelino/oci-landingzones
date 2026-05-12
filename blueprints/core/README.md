# Core Landing Zone Blueprint

The core blueprint is the mandatory baseline for every OCI landing zone
deployment. It creates shared identity, security, governance, and operational
controls used by all other blueprints.

> [DIAGRAM REQUIRED] `docs/architecture/diagrams/01-iam-compartments.excalidraw`
>
> Status: TODO - scaffold files may exist now; create this diagram before adding
> real OCI resources or applying Terraform.

## Responsibilities

- Root landing zone compartment.
- Network, security, governance, and workload compartments.
- Platform IAM groups and least-privilege policies.
- Dynamic groups for service integrations.
- Tag namespace and tag defaults.
- Cloud Guard baseline.
- Security Zones baseline.
- Vault and customer-managed key baseline.
- Audit, service logging, events, budgets, and monitoring alarms.

## Module Order

1. `modules/governance/tagging`
2. `modules/iam/compartments`
3. `modules/iam/groups`
4. `modules/iam/dynamic-groups`
5. `modules/iam/policies`
6. `modules/security/vault`
7. `modules/security/cloud-guard`
8. `modules/security/security-zones`
9. `modules/governance/logging`
10. `modules/governance/events`
11. `modules/governance/budgets`
12. `modules/operations/monitoring`

## Expected Outputs

- `root_compartment_id`
- `network_compartment_id`
- `security_compartment_id`
- `governance_compartment_id`
- `workloads_compartment_id`
- `group_ids`
- `policy_ids`
- `tag_namespace_id`
- `vault_id`
- `notification_topic_ids`

## Implementation Notes

- Tags must be created before resources that consume tag defaults.
- IAM policies should avoid granting workload teams permissions outside their
  operating entity compartments.
- Core should expose stable outputs for networking, operating entity, and
  extension blueprints.
