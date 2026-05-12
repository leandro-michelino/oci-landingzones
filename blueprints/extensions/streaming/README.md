# Streaming Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this extension when workloads need managed event streaming, decoupled messaging, or
integration pipelines.

## What It Does

This extension gives event-driven workloads a managed streaming foundation. It covers
stream pools, producer and consumer access, retention, partition choices, private
access, monitoring, and the ownership model for teams publishing or reading events.

## Why Use It

Use this when event flow is a first-class part of the platform. Streaming needs producer
and consumer access, network paths, and retention choices made deliberately.

## When To Use It

- Apps need Kafka-compatible or OCI Streaming style event flows.
- Producer and consumer teams need scoped access.
- Event retention, logging, and private access matter.

## Pattern

- OCI Streaming streams and stream pools.
- Producer and consumer access policies.
- Optional private endpoint access.
- Monitoring, alarms, and retention settings.

## Prerequisites

- `blueprints/core` deployed.
- Workload compartment and IAM groups defined.
- Network access model decided if private producers or consumers are used.

## Inputs To Decide

- Stream pool compartment.
- Stream names and partition counts.
- Retention period.
- Producer and consumer groups.
- Private endpoint requirement.
- Monitoring thresholds.

## Deployment Flow

1. Confirm producer and consumer applications.
2. Complete the local architecture diagram.
3. Populate local ignored tfvars.
4. Run Terraform validation and plan.
5. Apply after data retention and access rules are reviewed.

## Architecture Artifacts

- Source diagram: `architecture/streaming.excalidraw`
- Exported image: `architecture/streaming.png`
