# Hello Python Function Sample

This is a tiny starter function for the Oracle Functions blueprint. It follows
the same Python FDK shape used by the Fn Project tooling: build an image, push it
to OCIR, then point `functions.hello.image` at that immutable tag in local
`terraform.tfvars`.

For broader deployment examples, see Oracle's
[sample catalog](https://docs.oracle.com/en-us/iaas/Content/Functions/Tasks/functionsdownloadingsamples_topic-Sample_functions.htm)
and the
[oracle-functions-samples](https://github.com/oracle-samples/oracle-functions-samples)
repository.

## Files

```text
samples/hello-python/
|-- Dockerfile
|-- func.py
|-- func.yaml
|-- requirements.txt
`-- README.md
```

## Build And Push

Set the repository URL from the blueprint output or from your approved OCIR
repository naming standard:

```bash
export IMAGE_URL="eu-madrid-1.ocir.io/<namespace>/acme-prod-mad-functions/hello-python:0.1.0"

docker build -t "${IMAGE_URL}" .
docker push "${IMAGE_URL}"
```

Then use the same image in `terraform.tfvars`:

```hcl
enable_functions = true
functions = {
  hello = {
    image              = "eu-madrid-1.ocir.io/<namespace>/acme-prod-mad-functions/hello-python:0.1.0"
    memory_in_mbs      = 256
    timeout_in_seconds = 30
  }
}
```

## Local Shape

The handler accepts JSON such as:

```json
{"name":"landing zone"}
```

and returns a JSON response with the function and application names supplied by
the Functions runtime context.
