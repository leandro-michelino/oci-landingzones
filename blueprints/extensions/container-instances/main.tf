# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
resource "oci_container_instances_container_instance" "this" {
  count = var.enable_container_instance ? 1 : 0

  availability_domain                  = var.availability_domain
  compartment_id                       = local.target_compartment_ocid
  display_name                         = local.display_name
  fault_domain                         = var.fault_domain
  shape                                = var.shape
  container_restart_policy             = var.container_restart_policy
  graceful_shutdown_timeout_in_seconds = var.graceful_shutdown_timeout_in_seconds
  defined_tags                         = var.defined_tags
  freeform_tags                        = local.common_freeform_tags

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  vnics {
    subnet_id              = var.subnet_id
    display_name           = coalesce(var.vnic_display_name, "${local.display_name}-vnic")
    hostname_label         = local.hostname_label
    is_public_ip_assigned  = var.is_public_ip_assigned
    nsg_ids                = var.nsg_ids
    private_ip             = var.private_ip
    skip_source_dest_check = var.skip_source_dest_check
    defined_tags           = var.defined_tags
    freeform_tags          = local.common_freeform_tags
  }

  dynamic "containers" {
    for_each = var.containers

    content {
      display_name                   = coalesce(containers.value.display_name, "${local.display_name}-container-${containers.key + 1}")
      image_url                      = containers.value.image_url
      command                        = containers.value.command
      arguments                      = containers.value.arguments
      environment_variables          = containers.value.environment_variables
      working_directory              = containers.value.working_directory
      is_resource_principal_disabled = containers.value.is_resource_principal_disabled
      defined_tags                   = var.defined_tags
      freeform_tags                  = local.common_freeform_tags

      dynamic "resource_config" {
        for_each = containers.value.resource_config_memory_limit_in_gbs == null && containers.value.resource_config_vcpus_limit == null ? [] : [containers.value]

        content {
          memory_limit_in_gbs = resource_config.value.resource_config_memory_limit_in_gbs
          vcpus_limit         = resource_config.value.resource_config_vcpus_limit
        }
      }

      dynamic "volume_mounts" {
        for_each = containers.value.volume_mounts

        content {
          volume_name  = volume_mounts.value.volume_name
          mount_path   = volume_mounts.value.mount_path
          is_read_only = volume_mounts.value.is_read_only
          partition    = volume_mounts.value.partition
          sub_path     = volume_mounts.value.sub_path
        }
      }

      dynamic "health_checks" {
        for_each = containers.value.health_checks

        content {
          health_check_type        = health_checks.value.health_check_type
          name                     = health_checks.value.name
          path                     = health_checks.value.path
          port                     = health_checks.value.port
          failure_action           = health_checks.value.failure_action
          failure_threshold        = health_checks.value.failure_threshold
          initial_delay_in_seconds = health_checks.value.initial_delay_in_seconds
          interval_in_seconds      = health_checks.value.interval_in_seconds
          success_threshold        = health_checks.value.success_threshold
          timeout_in_seconds       = health_checks.value.timeout_in_seconds

          dynamic "headers" {
            for_each = health_checks.value.headers

            content {
              name  = headers.value.name
              value = headers.value.value
            }
          }
        }
      }
    }
  }

  dynamic "image_pull_secrets" {
    for_each = var.image_pull_secrets

    content {
      registry_endpoint = image_pull_secrets.value.registry_endpoint
      secret_type       = image_pull_secrets.value.secret_type
      username          = image_pull_secrets.value.username
      password          = image_pull_secrets.value.password
      secret_id         = image_pull_secrets.value.secret_id
    }
  }

  dynamic "dns_config" {
    for_each = length(var.dns_nameservers) == 0 && length(var.dns_searches) == 0 && length(var.dns_options) == 0 ? [] : [1]

    content {
      nameservers = var.dns_nameservers
      searches    = var.dns_searches
      options     = var.dns_options
    }
  }

  dynamic "volumes" {
    for_each = var.volumes

    content {
      name          = volumes.value.name
      volume_type   = volumes.value.volume_type
      backing_store = volumes.value.backing_store

      dynamic "configs" {
        for_each = volumes.value.configs

        content {
          file_name = configs.value.file_name
          path      = configs.value.path
          data      = configs.value.data
        }
      }
    }
  }
}

resource "oci_identity_policy" "access" {
  count = length(var.policy_statements) > 0 ? 1 : 0

  compartment_id = local.policy_compartment_ocid
  name           = "${local.name_prefix}-container-instances-policy"
  description    = "Scoped OCI Container Instances access for ${local.name_prefix}."
  statements     = var.policy_statements
  defined_tags   = var.defined_tags
  freeform_tags  = local.common_freeform_tags
}
