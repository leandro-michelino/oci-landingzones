# Event-Driven Application Platform

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

## Use Cases

| Use Case | Why This Blueprint Fits |
| --- | --- |
| Async application backbone | Combines Events, Streaming, Notifications, and Service Connector Hub for decoupled workload hand-offs. |
| Object Storage event processing | Routes bucket events into streams, topics, functions, or archive targets for downstream automation. |
| AI automation trigger layer | Provides event rules and stream contracts for agent, function, or data-processing automation. |
| Integration pipeline foundation | Lets integration teams standardize archive bucket, stream pool, topic, connector, and IAM decisions. |
| Event audit and replay pattern | Archives events and streams so teams can inspect, replay, or feed operational evidence workflows. |

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

## Deployment Notes

- Leave `retention_in_hours` unset unless the tenancy service limits and region
  have been checked. Some test tenancies reject explicit low retention values.
- Connector target fields are target-specific. Object Storage targets use
  `namespace`, `bucket`, and `object_name_prefix`; notification targets use
  `topic_id`; stream targets use `stream_id`; function targets use
  `function_id`.
- Events rules can target Notifications without a stream. ONS-only actions
  should not require `stream_id`.
- Service Connector Hub needs IAM statements for its source and target services.
  Check the policy statement quota before enabling `policy_statements` in
  crowded tenancies.
- OCI-managed `Oracle-Tags` are preserved when no `defined_tags` are supplied.

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
