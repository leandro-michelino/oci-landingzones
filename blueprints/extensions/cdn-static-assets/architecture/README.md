# CDN Static Asset Distribution Architecture

## Deployment Purpose

This blueprint gives application teams a deployable OCI origin for sensitive
document downloads and public-safe static assets. It keeps Object Storage
private, uses PARs for authenticated private downloads, and produces a hand-off
contract for Cloudflare at OCI or an existing Cloudflare account.

## Architecture At A Glance

| Layer | Components |
| --- | --- |
| Private origin | Object Storage bucket with `NoPublicAccess`, versioning, optional KMS, and object events. |
| Private download | Backend-generated ObjectRead PARs for per-user documents. |
| Static edge | Cloudflare at OCI or external Cloudflare for approved public-safe prefixes, with optional Terraform-managed Cloudflare DNS, cache ruleset, Worker, and route. |
| Operations | Optional lifecycle rules, optional OCI DNS CNAME, optional Cloudflare edge resources, and real lifecycle test runner. |
| Handoff | Bucket name, origin host/path, PAR broker sample, and CDN/DNS contract outputs. |

## Architecture

```text
+--------------------------------------------------------------------------------+
|                      CDN Static Asset Distribution                              |
+--------------------------------------------------------------------------------+
|                                                                                |
|  Private Document Path                                                         |
|      |                                                                         |
|      v                                                                         |
|  Client application -> backend PAR broker                                      |
|      |                                                                         |
|      | create short-lived ObjectRead PAR                                       |
|      v                                                                         |
|  Private Object Storage bucket (NoPublicAccess)                                |
|      |                                                                         |
|      `--> Direct PAR download with Cache-Control: private, no-store            |
|                                                                                |
|  Public-Safe Static Asset Path                                                 |
|      |                                                                         |
|      v                                                                         |
|  Cloudflare at OCI or external Cloudflare                                      |
|      |                                                                         |
|      | optional DNS, cache rule, Worker smoke proxy, route                    |
|      v                                                                         |
|  OCI origin contract or Worker-held PAR                                       |
|      |                                                                         |
|      `--> Object Storage bucket or app-controlled origin                       |
|                                                                                |
|  Governance Lane                                                               |
|      |                                                                         |
|      +--> optional lifecycle policy                                            |
|      +--> optional OCI DNS CNAME                                               |
|      +--> optional IAM policy shell                                            |
|      `--> real lifecycle runner: apply, OCI verify, PAR curl, destroy          |
+--------------------------------------------------------------------------------+
```

## Terraform Components

| File | Purpose |
| --- | --- |
| `main.tf` | Creates the private bucket, sample objects, PARs, lifecycle policy, optional DNS CNAME, and optional IAM policy. |
| `variables.tf` | Defines bucket ownership, sample objects, PARs, lifecycle rules, CDN mode, OCI DNS, Cloudflare DNS/cache/Worker options, tags, and policy inputs. |
| `outputs.tf` | Exposes bucket, origin URL, sample URLs, sensitive PAR URLs, Cloudflare resource IDs, and CDN hand-off details. |
| `samples/` | Provides real lifecycle, Cloudflare hand-off, PAR-only, and Python backend broker examples. |
| `scripts/test-cdn-static-assets-lifecycle.sh` | Runs a real create, verify, PAR curl, destroy, and cleanup test from ignored local tfvars. |

## Request And Deployment Flow

1. Application owner classifies assets as private documents or public-safe static assets.
2. Platform owner deploys or references the private Object Storage origin bucket.
3. Test owner optionally enables synthetic objects and a Terraform-managed smoke-test PAR.
4. Backend owner deploys the PAR broker sample or equivalent application logic.
5. Edge owner provisions Cloudflare at OCI or uses an approved external Cloudflare account.
6. DNS owner optionally creates an OCI DNS CNAME or Terraform creates a Cloudflare proxied DNS record for a disposable external-account test.
7. Test owner optionally enables the Cloudflare Worker smoke proxy to hide a PAR URL behind the Cloudflare hostname.
8. Test owner runs the lifecycle script and confirms `apply=0 verify=0 destroy=0 post_destroy=0`.

## Traffic And Trust Boundaries

- The Object Storage bucket remains private with `NoPublicAccess`.
- PAR URLs are bearer credentials. Keep generated output files, CI logs, and
  local test workspaces protected when a smoke-test PAR is enabled.
- Private documents should use short TTLs and `Cache-Control: private, no-store`.
- Cloudflare cache rules should apply only to approved public-safe prefixes.
- Cloudflare account provisioning, activation, and DNS zone onboarding remain
  outside the OCI-managed deployment boundary.
- Terraform can create disposable Cloudflare DNS, cache rules, Worker scripts,
  and Worker routes when `CLOUDFLARE_API_TOKEN` is supplied.
- KMS key choice, retention needs, and object classification remain customer
  security decisions.

## Detailed Architecture Notes

- The current OCI-aligned CDN direction is Cloudflare at OCI, not an `oci_cdn_*`
  Terraform resource.
- Terraform-managed PARs are intentionally documented as smoke-test artifacts.
  Production PARs should be created at request time by an authenticated backend.
- The committed real lifecycle sample disables Object Storage lifecycle policy
  creation for broader tenancy compatibility.
- Lifecycle policies remain supported by the blueprint and should be enabled
  after the target compartment has the required Object Storage service-principal
  IAM grant.
- Optional OCI DNS CNAME creation requires an existing OCI DNS public zone and a
  Cloudflare target hostname.
- The Worker smoke-proxy path is the portable external Cloudflare test because
  it keeps the upstream PAR URL in a Worker secret binding.
- Cloudflare origin rules with Host Header override can be entitlement-dependent.
  Keep `create_cloudflare_origin_ruleset = false` unless the account is approved
  for that feature.
- The blueprint can reference an existing private bucket for brownfield
  PAR-only tests by setting `create_asset_bucket = false`.

## Operational Boundaries

- Terraform does not provision a Cloudflare at OCI subscription.
- Terraform can create the optional Cloudflare DNS, cache ruleset, Worker script,
  and Worker route for external-account tests.
- Terraform does not create Cloudflare WAF policy sets or production edge
  governance.
- Terraform does not implement customer authentication or authorization logic.
- The Python broker sample demonstrates PAR creation but is not a complete API
  service.
- Customer CDN monitoring should combine OCI Object Storage metrics with the
  selected Cloudflare account metrics.

## Test Evidence

Real lifecycle evidence from 2026-06-05:

| Check | Result |
| --- | --- |
| OCI-only run | `DEFAULT` in `af-johannesburg-1` created a private/versioned bucket, sample objects, and a PAR; direct PAR `curl` returned the expected synthetic statement; destroy left no managed resources. |
| Full Cloudflare run | Created Cloudflare DNS, cache ruleset, Worker script, Worker route, OCI bucket, sample objects, and PARs; Cloudflare `curl` returned `HTTP/2 200`, `x-oci-lz-cloudflare-proxy: worker`, and the expected smoke-test body. |
| Cleanup | Terraform destroyed all 11 resources, state was empty, OCI bucket readback returned `BucketNotFound`, Cloudflare DNS/ruleset readbacks returned not found, and the Worker script returned `404`. |

## Review Checklist

- Asset classes and cache eligibility are documented.
- Bucket ownership and compartment placement are approved.
- Private documents have a short TTL and no-store cache policy.
- Public-safe prefixes are explicitly named before Cloudflare cache rules are enabled.
- PAR generation is handled by backend code for production.
- Optional lifecycle policies have the required service-principal IAM policy.
- Optional DNS CNAME values are provided by the edge team.
- The real lifecycle test passed and destroyed its disposable resources.
