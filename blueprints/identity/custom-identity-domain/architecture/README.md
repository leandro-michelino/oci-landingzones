# Architecture

Keep the deployment diagram source and exported image in this folder.

- `custom-identity-domain.excalidraw`
- `custom-identity-domain.png`

The diagram should show the existing identity domain, external IdP if used, group
mappings, policy bindings, and operational ownership.

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
