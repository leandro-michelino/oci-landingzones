# Operations Blueprints

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

This family contains deployable landing-zone patterns for operating OCI after
the foundation is in place. Think cost control, backup posture, runbook-facing
automation, and the guardrails that keep a tenancy healthy after day one.

Each child folder follows the standard repo contract: Terraform files, local
Ansible runners, operator README, and detailed ASCII architecture notes.

## Deployments

| Deployment | Use It When |
|---|---|
| [Cost Optimization](cost-optimization/) | You need cost tags, budget thresholds, FinOps notifications, optional Optimizer profiles, and clean hand-offs for finance and platform teams. |
