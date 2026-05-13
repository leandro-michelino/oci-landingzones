# Architecture

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Keep architecture notes in this folder. Add rendered artifacts only when a review package needs them.

The diagram should show the DRG, hub VCN, spoke VCNs, attachments, route tables, subnet
tiers, and intended traffic flows.

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
