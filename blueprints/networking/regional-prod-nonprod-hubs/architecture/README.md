# Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Expected editable diagram:

```text
docs/architecture/diagrams/15-regional-prod-nonprod-hubs.excalidraw
```

Expected exported image:

```text
docs/architecture/exports/15-regional-prod-nonprod-hubs.png
```

The diagram should show prod and nonprod hubs, DRG routing boundaries, inspection,
shared services, and workload spoke attachment rules.

## Why This Diagram Matters

The diagram is the quick sanity check before anyone opens Terraform. It should make the
traffic paths, ownership boundaries, dependencies, and operational hand-offs obvious
enough that a customer, network engineer, security reviewer, and platform engineer can
point at the same picture and agree on what is being built.

## When To Update It

- The blueprint adds or removes a major resource type.
- A route, trust boundary, region, compartment, or access path changes.
- A customer-specific assumption becomes part of the reusable pattern.
- The README explains a behavior that is not visible in the diagram yet.
