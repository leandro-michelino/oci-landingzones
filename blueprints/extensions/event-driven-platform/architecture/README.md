# Event-Driven Application Platform Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

## Deployment Purpose

Create a reusable event-driven foundation for asynchronous applications and AI
automation. The blueprint wires event sources, stream buffers, notification
targets, archive storage, service connectors, and IAM hand-offs in one extension
folder.

## Architecture At A Glance

| Layer | Responsibility |
| --- | --- |
| Events rules | Match OCI events and dispatch actions. |
| Streaming | Durable event buffers and dead-letter style topics. |
| Service Connector | Moves stream events to archive, function, stream, or topic target. |
| Notification topic | Alerting and human notification hand-off. |
| Archive bucket | Long-term event payload storage. |
| IAM policy | Service and operator permissions. |

## ASCII Architecture

```text
OCI Services / Apps / Buckets
        |
        | events
        v
OCI Events Rules
 |-- action: Streaming
 |-- action: Functions
 `-- action: Notifications
        |
        v
Streaming Pool
 |-- events stream
 `-- deadletter stream
        |
        v
Service Connector Hub
 |-- Object Storage archive
 |-- Function processor
 |-- Notification topic
 `-- Downstream stream
        |
        v
Async Apps / AI Pipelines / Operators
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Archive bucket, streams, topic, Events rules, Service Connector, IAM. |
| `variables.tf` | Event, stream, connector, topic, bucket, and policy inputs. |
| `outputs.tf` | Stream, topic, event rule, connector, bucket, and policy outputs. |
| `terraform.tfvars.example` | Example rule and disabled create flags. |
| `ansible/*.yml` | Standard local runners. |

## Request And Deployment Flow

1. Identify event producers and event types.
2. Decide stream names, partitions, and retention.
3. Decide archive and dead-letter behavior.
4. Configure Events rule conditions and actions.
5. Configure Service Connector target.
6. Hand stream/topic outputs to app or AI pipeline owners.

## Traffic And Trust Boundaries

- Events can carry resource names and metadata that may be sensitive.
- Function targets need least-privilege resource access.
- Archive buckets should be private and retention-managed.
- Stream readers should be scoped to the owning application or pipeline.
- Notification topics should point to approved operational channels.

## Detailed Architecture Notes

This blueprint is intentionally generic because many workloads share the same
async foundation: object-created pipelines, AI automation, integration events,
and operational fan-out. The event rules map lets teams add new event actions
without changing the resource layout.

Service Connector Hub is optional. Some designs send Events directly to
Functions or Streaming. Others need a connector to archive or transform records.
The folder supports both patterns.

The blueprint can be used as an extension-only brownfield add-on by supplying
existing stream, topic, bucket, and function IDs.

## Operational Boundaries

- Do not commit customer event payloads or private function IDs.
- Keep rule conditions and target IDs in ignored tfvars.
- Use `genai-guardrails` when event payloads contain prompt or model metadata.
- Use Functions and Streaming extensions for service-specific runtime details.

## Review Checklist

- [ ] Event conditions match only intended producers.
- [ ] Stream retention and partition count are approved.
- [ ] Connector target and archive prefix are reviewed.
- [ ] Notification topic ownership is clear.
- [ ] IAM statements are scoped to producer and consumer teams.
- [ ] Outputs are handed to approved application owners.
