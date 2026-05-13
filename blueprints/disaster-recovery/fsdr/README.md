# Full Stack Disaster Recovery Blueprint

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This blueprint is for OCI Full Stack Disaster Recovery deployments where failover and
switchover need to be orchestrated across the application stack, not just handled as
separate infrastructure pieces.

## What It Does

This blueprint wraps a workload with OCI Full Stack Disaster Recovery orchestration. It
focuses on DR protection groups, switchover and failover plans, replicated dependencies,
DNS/load-balancer behavior, notifications, and the runbook steps operators need during a
drill or real event.

## Why Use It

Use this when DR has to move the full application stack, not just a few replicated
resources. FSDR is the orchestration layer for plans, drills, failover, and switchover.

## When To Use It

- The workload needs tested failover or switchover.
- Compute, database, DNS, load balancing, and runbooks must move together.
- The customer wants DR plans that operators can rehearse.

## Fit

- Production workloads with tested disaster recovery requirements.
- Cross-region or cross-availability-domain recovery.
- Applications where compute, database, load balancing, DNS, networking, and operational
  runbooks must move together.

## Expected Composition

- Primary and standby region provider configuration.
- DR protection groups.
- DR plans for switchover, failover, and start drill.
- Replicated network, compute, storage, database, DNS, and load balancer dependencies.
- Monitoring, events, notifications, and runbook automation hooks.
- Optional integration with dual-region hub-spoke networking.

## Deployment Notes

Deploy core in both regions first, then deploy the required networking and workload
foundations. Use this blueprint to bind the workload resources into FSDR protection
groups and plans.

Keep drill and failover plan execution separate from normal Terraform apply until the
runbook flow is explicitly reviewed.

## Architecture

Detailed ASCII architecture notes live in `architecture/README.md`.
