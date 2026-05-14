# Security Posture Automation

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this blueprint when security teams need a repeatable extension for Cloud
Guard targeting, Vulnerability Scanning, event-driven remediation hooks, report
archives, alarms, and least-privilege IAM hand-offs.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/compliance/security-posture` |
| Best fit | Cloud Guard + Vulnerability Scanning + Events automation for protected compartments. |
| Terraform shape | Report bucket, ONS topic, Cloud Guard target, VSS host recipe/target, Events rules, alarms, IAM policy. |
| Default posture | Scanning and response resources are disabled until scope and recipes are approved. |
| Customer paths | Extension-only on an existing Core baseline, or base-plus-extension after Core/CIS. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Report archive bucket | `create_report_bucket` |
| Notifications topic | `create_topic` |
| Cloud Guard target | `create_cloud_guard_target` |
| VSS host scan recipe and target | `create_host_scan_recipe`, `create_host_scan_target` |
| Events rules and actions | `event_rules` map |
| Monitoring alarms | `alarms` map |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `cloud_guard_target_resource_id` | Compartment or scope protected by Cloud Guard. |
| `detector_recipe_ids`, `responder_recipe_ids` | Oracle-managed or customer recipes attached to the target. |
| `host_scan_target_compartment_id` | Compartment covered by VSS host scanning. |
| `event_rules` | Notify-only vs function-based remediation action paths. |
| `policy_statements` | Security admin, responder, scanner, and auditor boundaries. |

## Deployment Order

1. Confirm the protected compartment scope and control owner.
2. Decide Cloud Guard detector/responder recipes.
3. Decide host scanning schedule, target compartment, and instance scope.
4. Wire event actions to ONS, Functions, or Streaming.
5. Run `terraform plan` or `ansible-playbook ansible/plan.yml`.
6. Apply after responder automation is reviewed in notify-only or enforce mode.

## Outputs

| Output | Meaning |
| --- | --- |
| `cloud_guard_target_id` | Cloud Guard target OCID. |
| `host_scan_recipe_id` | VSS host scan recipe OCID. |
| `host_scan_target_id` | VSS host scan target OCID. |
| `report_bucket_name` | Report archive bucket. |
| `event_rule_ids` | Events rule OCIDs. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```

Review `architecture/README.md` before enabling automatic responders.
