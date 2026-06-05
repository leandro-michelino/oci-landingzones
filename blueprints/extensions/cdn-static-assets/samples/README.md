# CDN Static Asset Distribution Samples

These examples are public-safe input shapes. Put real OCIDs, bucket names,
regions, and profile names in ignored local tfvars files such as
`.leo-local/cdn-static-assets.tfvars`.

## Real Lifecycle Smoke Test

Use `real-lifecycle.tfvars.example` to create a disposable private bucket,
synthetic public and private objects, and a Terraform-managed PAR. The
repository-level test script validates the bucket with OCI CLI and downloads the
private sample through the PAR URL.

```bash
mkdir -p .leo-local
cp blueprints/extensions/cdn-static-assets/samples/real-lifecycle.tfvars.example \
  .leo-local/cdn-static-assets.tfvars
```

Edit the OCIDs, profile, region, and `asset_bucket_name`, then run:

```bash
CDN_STATIC_ASSETS_LIFECYCLE_CONFIRM=true \
  scripts/test-cdn-static-assets-lifecycle.sh \
  --var-file .leo-local/cdn-static-assets.tfvars \
  --profile NON_DEFAULT_TEST \
  --region us-ashburn-1
```

The script destroys by default after verification. Use `--keep-resources` only
when a reviewer needs to inspect the resources manually.

The sample keeps `create_lifecycle_policy = false` for broad tenancy
compatibility. Enable it only after the Object Storage service-principal policy
for lifecycle management is approved in the target compartment.

## Cloudflare At OCI Handoff

Use `cloudflare-handoff.tfvars.example` when the OCI side owns the bucket and
the edge team will provision Cloudflare at OCI through OCI Partner Offerings.
The Terraform outputs provide the Object Storage origin host, origin path, and
DNS hand-off values.

Enable `create_dns_cname` only after Cloudflare returns the target hostname and
OCI DNS owns the public zone.

## Full External Cloudflare Smoke Test

Use `cloudflare-worker-full.tfvars.example` when you have a Cloudflare account,
zone, and API token and want Terraform to create the disposable Cloudflare DNS
record, cache rule, Worker script, Worker route, OCI bucket, OCI objects, and
PAR-backed smoke test. Set `CLOUDFLARE_API_TOKEN` in the shell; do not put the
token in tfvars.

The Worker path is the portable default for this smoke test because it hides
the OCI PAR URL in a Worker secret binding. Cloudflare origin rules with Host
Header override are still modeled, but many non-Enterprise accounts are not
entitled for that feature.

## PAR-Only Existing Bucket

Use `par-only-existing-bucket.tfvars.example` when a customer already has an
approved private bucket and only needs smoke-test PAR creation from Terraform.
For production, keep PAR generation in an authenticated backend service instead
of storing generated PAR URLs in IaC-managed local files.

## Ideas To Adapt

| Idea | Implementation Direction |
| --- | --- |
| Fintech statements | Keep generated statements under `private/`, use the backend PAR broker with a 15-minute TTL, and never cache the response at the CDN. |
| Healthtech imaging exports | Place patient-specific exports under a private prefix and issue one ObjectRead PAR per authorized request. |
| ISV release assets | Publish immutable public-safe files under `public/releases/<version>/` and cache that prefix through Cloudflare at OCI. |
| Mobile app assets | Use content-hashed filenames under `public/mobile/` and long cache TTLs after the release pipeline approves the artifact. |
| Partner data exchange | Use scoped prefix PARs for short collaboration windows, with object listing disabled unless explicitly required. |
