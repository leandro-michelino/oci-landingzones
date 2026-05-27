# Industry Blueprints

Industry blueprints are opinionated landing zones for workload families that
usually arrive with their own review path, owners, and operational rules. They
compose the shared building blocks in this repo into something closer to a
customer conversation: telco cloud-native platforms, secure desktop access, and
future vertical patterns.

## Current Blueprints

| Blueprint | Best Fit | Notes |
| --- | --- | --- |
| [Secure Desktops Landing Zone](secure-desktops/) | Managed VDI for contractors, regulated users, remote admins, or data-sensitive desktops. | Starts safely with desktop pool creation disabled until image, network, storage, BYOL, and user access decisions are approved. |
| [Telco Cloud Native Landing Zone](telco-cloud-native/) | Telco-oriented platform foundations with hub-spoke networking, DRG, OKE, Vault/KMS, monitoring, and OS Management hooks. | Can be deployed progressively: network foundation first, then Vault, OKE, monitoring, and OS Management as quotas and approvals are ready. |

## When To Use This Family

- The workload has a vertical operating model, not just a generic subnet or
  cluster need.
- Security, operations, and platform owners need one review surface.
- A customer wants a repeatable architecture that still leaves expensive or
  approval-heavy services behind enable flags.
- You need a real Terraform deployment folder with local Ansible plan/apply
  wrappers, architecture notes, and safe example inputs.

## Operator Flow

1. Pick the blueprint that matches the workload outcome.
2. Read the blueprint README and local `architecture/README.md`.
3. Start with the cost-controlled path where available.
4. Enable the heavier services only after quota, image, license, route, and
   access approvals are clear.
5. Run `terraform plan` or the local `ansible/plan.yml` wrapper before apply.
6. Destroy disposable validation stacks when the test window is finished.

## Cost And Quota Notes

- Secure Desktops pools require customer image, network, storage, capacity, and
  license decisions. The blueprint can still validate low-cost monitoring and
  IAM paths before creating desktops.
- The telco blueprint creates the network foundation by default. OKE, Vault,
  monitoring, and OS Management are controlled by explicit enable flags so you
  can stage a rollout instead of turning on everything at once.
- Keep local `terraform.tfvars`, state files, plans, and provider caches out of
  git. The root `.gitignore` already covers the normal Terraform artifacts.
