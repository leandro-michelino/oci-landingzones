locals {
  module_name = "iam-dynamic-groups"
  name_prefix = "${var.org}-${var.environment}-${var.region_key}"

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
