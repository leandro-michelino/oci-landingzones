locals {
  module_name = "governance-tagging"
  cis_level   = var.cis_level == null ? null : lower(var.cis_level)
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"
  namespace   = coalesce(var.tag_namespace_name, "${var.org}-tags")

  effective_tag_default_values = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "platform-team"
      Project     = "landingzone"
      Blueprint   = local.module_name
      CostCenter  = "unset"
      CreatedDate = "unset"
    },
    var.tag_default_values
  )

  tag_default_maps = [
    for compartment_key, compartment_id in var.tag_default_compartment_ids : {
      for tag_name, value in local.effective_tag_default_values : "${compartment_key}.${tag_name}" => {
        compartment_key = compartment_key
        compartment_id  = compartment_id
        tag_name        = tag_name
        value           = value
        is_required     = contains(var.required_tag_defaults, tag_name)
      }
      if contains(keys(var.tag_definitions), tag_name)
    }
  ]

  tag_defaults = length(local.tag_default_maps) == 0 ? {} : merge(local.tag_default_maps...)

  region_key_map = {
    eu-frankfurt-1    = "fra"
    uk-london-1       = "lhr"
    af-johannesburg-1 = "jnb"
    sa-saopaulo-1     = "gru"
    eu-amsterdam-1    = "ams"
    us-ashburn-1      = "iad"
    us-phoenix-1      = "phx"
    me-dubai-1        = "dxb"
    ap-sydney-1       = "syd"
    ap-tokyo-1        = "nrt"
  }
}
