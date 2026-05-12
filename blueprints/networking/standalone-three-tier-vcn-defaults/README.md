# Standalone Three-Tier VCN Defaults

Author: Leandro Michelino | ACE | leandro.michelino@oracle.com

Use this deployment when a team needs a simple internet-facing application VCN with
standard landing-zone defaults.

## What It Does

This blueprint is the simple internet-facing three-tier starter. It gives a team a
public web tier, private application and database tiers, NAT and service gateway paths,
and sane defaults for a normal app that does not need hub-spoke or custom routing yet.

## Why Use It

Use this for the classic web/app/database pattern when speed and sane defaults matter
more than bespoke network design. It is the clean starter VCN for normal internet-facing
apps.

## When To Use It

- The workload is simple or medium complexity.
- Internet ingress is required for a web tier.
- The customer does not yet need a hub-spoke or custom IP plan.

## Pattern

- One VCN.
- Public web tier with internet gateway access.
- Private application tier.
- Private database tier.
- NAT gateway for private outbound access.
- Service gateway for private OCI service access.
- Default route tables, security lists or NSGs, and DNS labels.

## Best Fit

- Small or medium workloads.
- Proofs of concept that should still follow a clean baseline.
- Internet-facing web applications with private application and data tiers.
- Teams that do not need custom CIDR design yet.

## Inputs To Decide

- Workload compartment target from `blueprints/core`, another landing-zone
  process, or an existing brownfield tenancy.
- VCN CIDR block.
- Public web subnet CIDR.
- Private application subnet CIDR.
- Private database subnet CIDR.
- Allowed ingress sources for web traffic.
- Egress policy for private tiers.

## Deployment Flow

1. Identify the target workload compartment OCID.
2. Review `architecture/README.md` and confirm the topology matches the
   workload.
3. Copy `terraform.tfvars.example` to a local ignored `terraform.tfvars` file.
4. Set `compartment_ocid` to the target workload compartment. If it is omitted,
   the blueprint falls back to `tenancy_ocid`, which is useful only for simple
   tests.
5. Run `terraform init`, `terraform validate`, and `terraform plan`.
6. Apply only after the plan matches the expected topology.

## Using Only This Blueprint

This blueprint composes the shared module at `modules/networking/spoke-vcn`.
When consuming only this pattern from GitHub, keep both paths in the same local
repository layout so the relative module source in `main.tf` resolves.

```bash
git clone --filter=blob:none --sparse https://github.com/leandro-michelino/oci-landingzones.git
cd oci-landingzones

git sparse-checkout set \
  blueprints/networking/standalone-three-tier-vcn-defaults \
  modules/networking/spoke-vcn

cd blueprints/networking/standalone-three-tier-vcn-defaults
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with real OCI values:

```hcl
tenancy_ocid        = "ocid1.tenancy.oc1..."
current_user_ocid   = "ocid1.user.oc1..."
region              = "eu-frankfurt-1"
home_region         = "eu-frankfurt-1"
oci_config_profile  = "DEFAULT"
compartment_ocid    = "ocid1.compartment.oc1..."
org                 = "acme"
environment         = "dev"
region_key          = "fra"
vcn_label           = "app"
vcn_cidr_block      = "10.10.0.0/16"
```

Then run:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

For validation without remote state, use `terraform init -backend=false`.

## Architecture Artifacts

- Source diagram: `architecture/standalone-three-tier-vcn-defaults.excalidraw`
- Exported image: generate a PNG from the source only when a rendered review artifact is needed.

## Notes

This is the default internet-only three-tier deployment. For customer-specific CIDRs,
use `standalone-three-tier-vcn-custom`. For private-only workloads, use
`standalone-private-endpoint-only`.
