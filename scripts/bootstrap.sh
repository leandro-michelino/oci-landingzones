#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/bootstrap.sh --org <org> --env <env> --region <oci-region>

Purpose:
  Prepare one-time prerequisites for an OCI landing zone deployment.

Current behavior:
  This bootstrap helper validates inputs and prints the manual prerequisites.
  Remote state provisioning will be implemented once the core backend contract
  is finalized.
USAGE
}

ORG=""
ENVIRONMENT=""
REGION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)
      ORG="${2:-}"
      shift 2
      ;;
    --env)
      ENVIRONMENT="${2:-}"
      shift 2
      ;;
    --region)
      REGION="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ORG" || -z "$ENVIRONMENT" || -z "$REGION" ]]; then
  echo "Missing required arguments." >&2
  usage
  exit 1
fi

cat <<EOF
Bootstrap context
-----------------
Organization : $ORG
Environment  : $ENVIRONMENT
Region       : $REGION

Manual prerequisites to confirm:
1. OCI CLI is installed and authenticated.
2. TENANCY_OCID is exported in the shell.
3. A remote state bucket and namespace naming decision exists.
4. Local or approved external secrets handling is defined.
5. pre-commit is installed locally.

Suggested validation:
  oci iam tenancy get --tenancy-id "\$TENANCY_OCID"
  pre-commit install
EOF
