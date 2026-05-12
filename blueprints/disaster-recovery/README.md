# Disaster Recovery Blueprints

Disaster recovery blueprints compose regional foundations, replication, runbooks, and
operational controls for workloads that need tested failover.

## What It Does

This is the catalog for recovery patterns that need more than standby infrastructure. It
keeps replication, regional foundations, FSDR plans, runbooks, monitoring, and operator
handoffs together so DR can be rehearsed, not just promised.

## Why Use It

Use this folder when the customer needs rehearsed recovery, not just replicated
infrastructure. DR is an operating model as much as a topology.

## When To Use It

- Use FSDR when plans, drills, failover, and switchover must be orchestrated.
- Pair it with dual-region networking when regional failover is required.
- Keep plan execution separate from normal apply until the runbook is approved.

## Blueprints

| Blueprint | Path | Purpose |
|---|---|---|
| FSDR | `fsdr/` | OCI Full Stack Disaster Recovery pattern for orchestrated failover and switchover across regions or availability domains. |
