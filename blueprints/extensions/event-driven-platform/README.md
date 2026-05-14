# Event-Driven Application Platform

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this extension when a customer needs a reusable async foundation with OCI
Events, Streaming, Service Connector Hub, Object Storage archive, Notifications,
and optional Functions hand-offs.

## At A Glance

| Item | Details |
| --- | --- |
| Folder | `blueprints/extensions/event-driven-platform` |
| Best fit | Event-driven apps, AI automation, integration pipelines, and async workload hand-offs. |
| Terraform shape | Archive bucket, stream pool, streams, notification topic, Events rules, Service Connector, IAM. |
| Customer paths | Extension-only with existing resources, or base-plus-extension after Core and Networking. |

## What This Deploys

| Resource | Enable Flag |
| --- | --- |
| Archive bucket | `create_archive_bucket` |
| Stream pool | `create_stream_pool` |
| Streams | `create_streams` |
| Notification topic | `create_topic` |
| Events rules | `create_event_rules` |
| Service Connector | `create_service_connector` |
| IAM policy shell | `policy_statements` not empty |

## Inputs To Decide

| Input | What To Decide |
| --- | --- |
| `event_rules` | Event conditions and target actions. |
| `streams` | Stream partitioning and retention. |
| `connector_*` | Source stream and target archive/function/topic/stream. |
| `policy_statements` | Events, Streaming, Functions, Notifications, and Object Storage access. |

## Deployment Order

For extension-only use, supply existing compartment, stream, topic, function,
bucket, and IAM values. For base-plus-extension use, deploy Core, Networking,
and optional Functions first, then enable the specific async resources here.

## Outputs

| Output | Meaning |
| --- | --- |
| `archive_bucket_name` | Event archive bucket name. |
| `stream_pool_id` | Streaming pool OCID. |
| `stream_ids` | Stream OCIDs keyed by logical name. |
| `notification_topic_id` | ONS topic OCID. |
| `event_rule_ids` | Events rule OCIDs. |
| `service_connector_id` | Service Connector OCID. |

## Validation

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
ansible-playbook ansible/plan.yml
```
