# Industry Blueprints

Industry blueprints capture repeatable OCI landing zone patterns that need
domain-specific assumptions beyond the generic platform foundation.

## What It Does

This is where industry-flavored landing-zone patterns live. These are not separate
products; they are opinionated compositions of core, networking, security,
observability, and extensions for customers whose industry changes what 'ready' really
means.

## Why Use It

Use this folder when a workload pattern has enough industry-specific assumptions that a
generic blueprint would hide the important bits.

## When To Use It

- Use telco cloud-native for OKE-heavy, private, segmented telco workloads.
- Add more industry blueprints when customer patterns repeat.
- Keep the industry assumptions explicit in the local README.

## Blueprints

| Blueprint | Path | Purpose |
|---|---|---|
| Telco cloud native | `telco-cloud-native/` | Telco-oriented cloud-native landing zone with OKE, network segmentation, private connectivity, and operations controls. |
