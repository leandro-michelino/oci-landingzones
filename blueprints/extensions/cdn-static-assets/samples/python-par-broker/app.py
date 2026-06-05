import datetime
import json
import os
import re
import sys

import oci
from oci.object_storage.models import CreatePreauthenticatedRequestDetails


def _config():
    profile = os.getenv("OCI_CONFIG_PROFILE")
    if profile:
        return oci.config.from_file(profile_name=profile)
    return oci.config.from_file()


def _safe_name(value):
    return re.sub(r"[^A-Za-z0-9_.-]", "-", value)[:180]


def create_object_read_par(object_name):
    config = _config()
    namespace = os.environ["OCI_OBJECT_STORAGE_NAMESPACE"]
    bucket = os.environ["OCI_ASSET_BUCKET"]
    ttl_minutes = min(max(int(os.getenv("PAR_TTL_MINUTES", "15")), 1), 60)
    expires_at = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(minutes=ttl_minutes)
    prefix = os.getenv("PAR_NAME_PREFIX", "download")

    client = oci.object_storage.ObjectStorageClient(config)
    details = CreatePreauthenticatedRequestDetails(
        name=_safe_name(f"{prefix}-{object_name}-{expires_at:%Y%m%d%H%M%S}"),
        access_type="ObjectRead",
        object_name=object_name,
        time_expires=expires_at,
    )
    response = client.create_preauthenticated_request(namespace, bucket, details)
    access_uri = response.data.access_uri
    return {
        "object_name": object_name,
        "expires_at": expires_at.isoformat(),
        "url": f"https://objectstorage.{config['region']}.oraclecloud.com{access_uri}",
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python app.py <object-name>")

    result = create_object_read_par(sys.argv[1])
    print(json.dumps(result, indent=2, sort_keys=True))
