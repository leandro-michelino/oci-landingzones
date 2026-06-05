# Python PAR Broker Sample

This sample shows the backend logic for creating a short-lived ObjectRead PAR at
request time. Use it from an app server, OCI Function, or API route that already
authenticated and authorized the end user.

## Environment

| Variable | Meaning |
| --- | --- |
| `OCI_ASSET_BUCKET` | Object Storage bucket that contains the requested object. |
| `OCI_OBJECT_STORAGE_NAMESPACE` | Object Storage namespace from the Terraform output. |
| `OCI_CONFIG_PROFILE` | Optional OCI CLI profile for local tests. |
| `PAR_TTL_MINUTES` | PAR TTL. Defaults to 15 minutes. |
| `PAR_NAME_PREFIX` | Optional PAR display-name prefix. |

## Local Test

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt

export OCI_CONFIG_PROFILE=NON_DEFAULT_TEST
export OCI_ASSET_BUCKET=demo-dev-iad-bkt-assets-origin
export OCI_OBJECT_STORAGE_NAMESPACE="$(terraform output -raw namespace)"
export PAR_TTL_MINUTES=15

python app.py private/demo-statement.txt
```

The command prints a JSON object with the URL and expiration timestamp. Treat
the URL as a bearer credential.
