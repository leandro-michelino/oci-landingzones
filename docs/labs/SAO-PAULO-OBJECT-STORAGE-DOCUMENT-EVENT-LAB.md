# Sao Paulo Object Storage Document And Event Lab

This lab deploys and tests two Object Storage-centered customer patterns in
`sa-saopaulo-1` using the OCI CLI profile `DEFAULT`.

## Permanent Deployment Identity

The permanent owner identity for deployments is:

```text
Leandro_Michelino
```

OCI and other cloud resource names in this repository must follow the target
cloud provider naming conventions. For OCI-managed names, this means lowercase
letters, numbers, and hyphens with no underscores. The technical `org` segment
used in resource names is:

```text
leandro-michelino
```

Every lab resource also carries the freeform tag `Owner = Leandro_Michelino`.
Use `Leandro_Michelino` for owner metadata, not for provider resource-name
segments that prohibit underscores or uppercase characters.

## Scope

The lab covers:

- Document Intelligence Pipeline:
  - intake, output, and failed Object Storage buckets
  - OCI Document Understanding project
  - real processor job test reading from the intake bucket and writing to the
    output bucket
- Event-Driven Application Platform:
  - Object Storage archive bucket
  - Streaming pool and streams
  - Notifications topic
  - Events rule for Object Storage create-object events
  - Service Connector Hub connector from Streaming to Object Storage archive
  - real upload test proving object event delivery and archive write

The lab uses a temporary compartment and must be destroyed after the real tests.

## Deployment Inputs

Use these local files, which are intentionally ignored by git:

```text
blueprints/ai/document-intelligence/terraform.tfvars
blueprints/extensions/event-driven-platform/terraform.tfvars
```

Both files target:

```text
profile: DEFAULT
region: sa-saopaulo-1
region_key: gru
owner: Leandro_Michelino
```

## Real Test Flow

1. Apply `blueprints/ai/document-intelligence`.
2. Apply `blueprints/extensions/event-driven-platform`.
3. Upload a real text document to the Document Intelligence intake bucket.
4. Run a real OCI Document Understanding processor job against that object.
5. Confirm a result object appears in the Document Intelligence output bucket.
6. Confirm the Object Storage create-object event reaches the configured stream.
7. Confirm Service Connector Hub writes archived event payloads to the archive bucket.
8. Destroy the Event-Driven Application Platform.
9. Destroy the Document Intelligence Pipeline.
10. Delete the temporary compartment after it is empty.

## Notes

The Document Intelligence blueprint accepts a `handler_function_id` for an
event-driven Function processor, but the Function image and subnet are outside
this blueprint. For this lab, the real Document Understanding processor job is
created by OCI CLI so the test remains end to end and cloud-backed without using
a placeholder Function.
