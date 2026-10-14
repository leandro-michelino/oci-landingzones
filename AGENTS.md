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
