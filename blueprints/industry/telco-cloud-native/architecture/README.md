# Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Expected editable diagram:

```text
docs/architecture/diagrams/17-telco-cloud-native.excalidraw
```

Expected exported image:

```text
docs/architecture/exports/17-telco-cloud-native.png
```

The diagram should show OKE, segmented subnets, private connectivity, service exposure,
observability, security scanning, and platform operations.

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
