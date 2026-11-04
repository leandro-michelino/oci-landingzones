# Repository Operating Instructions

## Truth Mode

Prioritize evidence over agreement. State uncertainty explicitly. Distinguish schema checks, mocked plans, live provisioning, workload behavior, and commercial estimates.

## Git Publication

- Publish completed, validated changes to `main`, as explicitly requested by the repository owner. Integrate existing remote commits and never force-push.
- Check the remote `main` hash after publication and confirm it matches the local commit. Do not describe a feature-branch push as publication to the default branch.
- Keep credentials, deployment state and saved plans, local tfvars, and private lifecycle evidence out of Git.

## Validation Metadata

- Keep validation comments and documentation in English. Record the last successful date, provider version, actual test scope, and evidence location.
- Update success metadata only after relevant checks pass. Preserve the prior success date after a failure and document the failure separately.
- Schema or mocked validation does not establish a successful live deployment. Record reduced lifecycle scope and verified cleanup explicitly.

## Cloud Tests

- Respect the account, region, compartment, and cost limits explicitly selected by the user in the current task. Authorization for one billed service does not authorize other billed services.
- Destroy ephemeral resources after successful or partial tests. Verify both managed state and cloud inventory before continuing.

## Diagram Presentation

- Keep exported architecture diagrams free of generic source-review dates, validation summaries and no-provisioning footers. Remove standalone source-audit paragraphs and lists of absent features from drawing generators and exports; keep validation scope and evidence in repository reports instead.
- Preserve technical connector legends, creation conditions, input defaults and architecture-specific prerequisites.
- For architecture diagrams, apply presentation changes in authoring generators and regenerate both editable draw.io and PNG artifacts, including companion resource/input pages.
- Publish banners and presentation graphics as PNG/SVG images only. Generate editable intermediates in a temporary directory; do not publish their draw.io files or editable-download links.

## Multicloud Transport Diagrams

- Prefer native Interconnect in supported connection locations, or an explicitly reviewed private partner circuit, for cross-cloud private workload traffic. VPN is a separately configured backup or alternative when dedicated connectivity cannot be used.
- FastConnect/Interconnect and VPN must use different, individually labelled connectors and distinct transport segments. Do not combine them in one line or overlay them. Retain official provider icons and the OCI toolkit's transport badges.
- Show external circuit activation, gateways, BGP/route policy and service limitations explicitly. Do not invent VPN support, private connectivity, encryption or automatic failover where the source does not implement them.
- Public CDN, public API and application replication relationships retain their actual HTTPS/application semantics; do not relabel them as physical Interconnect links.
