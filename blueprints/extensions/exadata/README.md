# Exadata Extension

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this extension when the landing zone needs Exadata infrastructure for database
workloads.

## What It Does

This extension places Exadata into the landing zone on purpose. It covers the database
network placement, client and backup paths, operational access, governance, and
ownership points that normally need DBAs, network, security, and platform teams in the
same conversation.

The Terraform can create Exadata Cloud Infrastructure, but it is disabled by default.
That is intentional: Exadata is high-cost, capacity-sensitive, and should only move
after database, network, finance, and operations people have all nodded.

## Why Use It

Use this when the database platform is big enough to shape the landing zone around it.
Exadata needs deliberate networking, backup, access, and operations design.

## When To Use It

- Exadata Cloud Service or Cloud@Customer integration is in scope.
- Database networks and backup paths need careful control.
- DBA and platform responsibilities must be clear.

## Pattern

- Optional Exadata Cloud Infrastructure.
- Dedicated database subnet placement.
- Backup, monitoring, and operational access assumptions.
- Integration with core IAM, tagging, and governance.

## Prerequisites

- `blueprints/core` deployed.
- Networking blueprint with database subnet capacity.
- Customer database sizing and licensing decisions.

## Inputs To Decide

- Exadata shape and capacity.
- Database subnet and backup subnet.
- DNS and client access path.
- Backup destination.
- Operational access model.
- Maintenance and patching ownership.

## Deployment Flow

1. Confirm database sizing and network placement.
2. Complete the local architecture notes.
3. Populate local ignored tfvars.
4. Run Terraform validation and plan.
5. Apply after database, network, and operations teams approve.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`
