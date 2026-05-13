# CIS Basic Identity

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when a tenancy needs a minimal CIS-aligned identity foundation
without adopting a full CIS landing zone profile.

## What It Does

This blueprint cleans up the first layer of OCI identity without forcing a full CIS
landing zone. It focuses on administrator and auditor separation, least-privilege
policies, MFA and break-glass assumptions, and the basic access model customers usually
want fixed early.

## Why Use It

Use this when identity needs to be cleaned up early, before the whole landing zone is
ready. It is a good first move when IAM is messy and everyone agrees access control
should stop being tribal knowledge.

## When To Use It

- You need a minimal CIS-flavored IAM baseline.
- The customer wants admin and auditor separation quickly.
- Identity hardening is urgent but the full CIS landing zone is not selected yet.

## Pattern

- Baseline administrator and auditor groups.
- Least-privilege IAM policies.
- MFA and password-policy assumptions documented for operations.
- Separation between platform administration and workload administration.

## Best Fit

- Smaller tenancies.
- Early governance baselines.
- Customers that want identity hardening before broader landing-zone rollout.

## Inputs To Decide

- Identity domain or tenancy IAM model.
- Administrator group names.
- Auditor group names.
- Break-glass access approach.
- MFA enforcement process.
- Policy scope.

## Deployment Flow

1. Review the architecture notes in this folder.
2. Confirm identity ownership with the customer security team.
3. Populate local ignored tfvars.
4. Run Terraform validation and plan.
5. Apply after IAM policy scope is reviewed.

## Architecture Artifacts

- Architecture notes: `architecture/README.md`
