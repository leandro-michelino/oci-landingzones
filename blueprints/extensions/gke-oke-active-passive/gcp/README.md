# GKE and OKE Active Passive - GCP Companion

This is an independent Terraform root using `infrastructure.tf`, with its own deployment state and separately authenticated ADC project credentials. It does not read the OCI root automatically.

Copy the disabled example inputs, enable only approved APIs and review `terraform plan` before applying. OCI profile DEFAULT does not authenticate Google Cloud. Existing project/billing and required Compute, service-specific and IAM APIs are prerequisites, not created resources.

Use `ansible/gcp-plan.yml`, `gcp-apply.yml` and `gcp-destroy.yml` from the parent blueprint. The shared Terraform runner enforces apply/destroy confirmation. Do not point this directory at OCI deployment state.

All creation flags default false. Protected inputs, credentials and saved plans must remain out of Git. Deletion protection and non-empty versioned buckets require explicit reviewed removal and data handling before teardown; do not force-destroy backups.

Local schema/mocked checks are configuration evidence only. No Google API discovery, deployment, workload execution, connectivity, replication or recovery test has been run.
