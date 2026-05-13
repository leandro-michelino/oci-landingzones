#!/usr/bin/env bash
# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com

terraform_env_is_true() {
  case "${1:-}" in
    1 | true | TRUE | yes | YES | y | Y | on | ON)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

terraform_env_append_godebug() {
  local flag="$1"

  if [[ ",${GODEBUG:-}," == *",$flag,"* ]]; then
    return 0
  fi

  export GODEBUG="${GODEBUG:+$GODEBUG,}$flag"
}

terraform_env_export_common() {
  export CHECKPOINT_DISABLE="${CHECKPOINT_DISABLE:-1}"
  export TF_IN_AUTOMATION="${TF_IN_AUTOMATION:-true}"
  export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${HOME}/.terraform.d/plugin-cache}"
  mkdir -p "$TF_PLUGIN_CACHE_DIR"

  if terraform_env_is_true "${TERRAFORM_ALLOW_LEGACY_X509_CN:-${TF_ALLOW_LEGACY_X509_CN:-false}}"; then
    terraform_env_append_godebug "x509ignoreCN=0"
  fi
}
