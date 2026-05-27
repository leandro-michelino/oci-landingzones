variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "compartment_ocid" {
  description = "Parent compartment OCID for resources managed by this module."
  type        = string
}

variable "region" {
  description = "OCI region name."
  type        = string
}

variable "org" {
  description = "Short organization prefix used in names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "region_key" {
  description = "Short OCI region key used in resource names."
  type        = string
}

variable "cis_level" {
  description = "CIS OCI Benchmark profile for the landing zone. Use level1 for baseline controls or level2 for stricter controls."
  type        = string
  default     = null

  validation {
    condition     = var.cis_level == null ? true : contains(["level1", "level2"], lower(var.cis_level))
    error_message = "cis_level must be either level1 or level2."
  }
}

variable "defined_tags" {
  description = "Defined tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "enable_tagging" {
  description = "Create the tag namespace and tag definitions. Disable for fast ephemeral tests that do not need defined tags."
  type        = bool
  default     = true
}

variable "enable_tag_defaults" {
  description = "Create tag defaults for landing zone compartments. Disable for faster ephemeral tests while keeping tag definitions."
  type        = bool
  default     = true
}

variable "tag_namespace_name" {
  description = "OCI tag namespace name. Defaults to <org>-tags."
  type        = string
  default     = null
}

variable "tag_namespace_description" {
  description = "Description for the OCI tag namespace."
  type        = string
  default     = "Landing zone tag namespace managed by Terraform."
}

variable "tag_definitions" {
  description = "Defined tags to create in the landing zone namespace."
  type = map(object({
    description      = string
    is_cost_tracking = optional(bool)
  }))
  default = {
    Environment = {
      description = "Deployment environment such as dev, uat, prod, or dr."
    }
    CostCenter = {
      description      = "Finance or chargeback cost center."
      is_cost_tracking = true
    }
    Owner = {
      description = "Owning team or operating entity."
    }
    Project = {
      description = "Project or workload identifier."
    }
    ManagedBy = {
      description = "Management source such as terraform or manual."
    }
    Blueprint = {
      description = "Landing zone blueprint that created or manages the resource."
    }
    CreatedDate = {
      description = "Creation date or onboarding date in ISO 8601 format."
    }
  }
}

variable "tag_default_compartment_ids" {
  description = "Map of compartment keys to OCIDs where tag defaults should be applied."
  type        = map(string)
  default     = {}
}

variable "tag_default_values" {
  description = "Map of tag names to default values applied as tag defaults."
  type        = map(string)
  default     = {}
}

variable "required_tag_defaults" {
  description = "Set of tag names whose tag defaults should be marked required."
  type        = set(string)
  default     = []
}
