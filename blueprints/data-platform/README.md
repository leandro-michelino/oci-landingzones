# Data Platform Blueprints

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Data platform blueprints focus on private analytics, data movement, service endpoints,
encryption, and controlled workload access.

## What It Does

This is the catalog for data-heavy landing-zone patterns. It is where private analytics,
streaming, object storage, encryption, producer/consumer boundaries, and controlled
service access get designed as a platform instead of a pile of one-off exceptions.

## Why Use It

Use this folder when data movement, private access, keys, and producer/consumer
boundaries are the main design problem.

## When To Use It

- Choose private data platform for analytics or lakehouse foundations.
- Pair it with private networking and Vault.
- Use workload vending when multiple data product teams need isolated spaces.

## Blueprints

| Blueprint | Path | Purpose |
|---|---|---|
| Private data platform | `private-data-platform/` | Private data landing zone for analytics, lakehouse, integration, and controlled data access. |
