mock_provider "oci" {}
mock_provider "oci" { alias = "home" }

variables {
  tenancy_ocid       = "ocid1.tenancy.oc1..example"
  current_user_ocid  = "ocid1.user.oc1..example"
  compartment_ocid   = "ocid1.compartment.oc1..example"
  region             = "sa-saopaulo-1"
  oci_config_profile = "DEFAULT"
  org                = "test"
  environment        = "dev"
  region_key         = "sao"
}

run "disabled_configuration_is_empty" {
  command = plan

  assert {
    condition = (
      length(oci_devops_project.this) == 0 &&
      length(oci_ons_notification_topic.this) == 0 &&
      length(oci_devops_repository.this) == 0 &&
      length(oci_devops_build_pipeline.this) == 0 &&
      length(oci_devops_deploy_pipeline.this) == 0
    )
    error_message = "The default configuration must not create DevOps or Notifications resources."
  }
}

run "project_requires_notification_topic" {
  command = plan
  variables { enable_devops_project = true }
  expect_failures = [var.enable_devops_project]
}

run "repository_requires_project" {
  command = plan
  variables { enable_repository = true }
  expect_failures = [var.enable_repository]
}

run "build_pipeline_requires_project" {
  command = plan
  variables { enable_build_pipeline = true }
  expect_failures = [var.enable_build_pipeline]
}

run "deploy_pipeline_requires_project" {
  command = plan
  variables { enable_deploy_pipeline = true }
  expect_failures = [var.enable_deploy_pipeline]
}

run "complete_project_shell_uses_created_topic" {
  command = plan
  variables {
    enable_devops_project     = true
    create_notification_topic = true
    enable_repository         = true
    enable_build_pipeline     = true
    enable_deploy_pipeline    = true
  }

  assert {
    condition = (
      length(oci_ons_notification_topic.this) == 1 &&
      length(oci_devops_project.this) == 1 &&
      length(oci_devops_repository.this) == 1 &&
      length(oci_devops_build_pipeline.this) == 1 &&
      length(oci_devops_deploy_pipeline.this) == 1
    )
    error_message = "An opted-in shell must contain one topic, project, repository, build pipeline, and deploy pipeline."
  }
}

run "existing_project_and_topic_are_reused" {
  command = plan
  variables {
    existing_project_id    = "mock-existing-project"
    notification_topic_id  = "mock-existing-topic"
    enable_repository      = true
    enable_build_pipeline  = true
    enable_deploy_pipeline = true
  }

  assert {
    condition = (
      length(oci_ons_notification_topic.this) == 0 &&
      length(oci_devops_project.this) == 0 &&
      length(oci_devops_repository.this) == 1 &&
      length(oci_devops_build_pipeline.this) == 1 &&
      length(oci_devops_deploy_pipeline.this) == 1 &&
      output.project_id == "mock-existing-project"
    )
    error_message = "Existing projects must be referenced without recreating a topic or project."
  }
}
