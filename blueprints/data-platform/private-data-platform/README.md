# Private Data Platform Landing Zone

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is for private analytics and data workloads that need controlled data
access, encryption, service endpoints, and private connectivity.

## What It Does

This blueprint gives data services a private and governed home. It is meant to connect
analytics, streaming, object storage, keys, private endpoints, service gateways,
logging, and access policies into one pattern that data teams can reuse without
bypassing the landing zone.

## Why Use It

Use this when data services need a private, governed home. It keeps analytics,
streaming, object storage, keys, and access paths controlled instead of leaving data
teams to assemble pieces ad hoc.

## When To Use It

- Private analytics or lakehouse workloads are planned.
- Data movement must avoid public exposure.
- Encryption, audit, and producer/consumer access need to be clear.

## Fit

- Lakehouse or analytics platforms.
- Private data integration and streaming workloads.
- Data services that should not rely on public ingress.

## Expected Composition

- Core compartment and IAM baseline.
- Private endpoint or private service access pattern.
- Service gateway and route controls.
- Vault and customer-managed keys.
- Object Storage, Streaming, and data service access policies.
- Logging, events, and monitoring for data access.

## Deployment Notes

Use this after core and a private networking pattern. Pair with workload vending when
multiple data product teams need isolated spaces.
