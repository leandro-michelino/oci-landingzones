"""Regression checks for diagram inventories; no Terraform or cloud execution."""
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch
import tempfile
import xml.etree.ElementTree as ET
import html
spec=importlib.util.spec_from_file_location('coverage',Path(__file__).with_name('multicloud-resource-coverage.py'))
coverage=importlib.util.module_from_spec(spec);spec.loader.exec_module(coverage)


class CreationGateTests(unittest.TestCase):
 def test_nested_dynamic_collection_does_not_enable_resource(self):
  src='''resource "oci_example" "this" {
  display_name = "sample"
  dynamic "rules" {
    for_each = var.rules
    content {
      name = rules.value.name
    }
  }
}
'''
  attrs=coverage.root_attributes(coverage.declaration_body(src,src.index('{')+1))
  self.assertNotIn('for_each',attrs)
  self.assertNotIn('count',attrs)

 def test_gate_does_not_leak_from_next_root_block(self):
  src='''resource "oci_example" "first" {
  display_name = "sample"
}
locals {
  count = 7
}
resource "oci_example" "second" {
  count = var.enabled ? 1 : 0
}
'''
  attrs=coverage.root_attributes(coverage.declaration_body(src,src.index('{')+1))
  self.assertNotIn('count',attrs)

 def test_multiline_creation_expression_is_preserved(self):
  body='''
  for_each = var.enabled ? {
    for key, value in var.nodes : key => value
    if value.enabled
  } : {}

  compartment_id = var.compartment_id
  dynamic "settings" {
    for_each = var.settings
  }
'''
  attrs=coverage.root_attributes(body)
  self.assertEqual(attrs['for_each'],'var.enabled ? {\n    for key, value in var.nodes : key => value\n    if value.enabled\n  } : {}')

 def test_rendered_health_monitor_card_keeps_all_creation_conditions(self):
  src='resource "oci_health_checks_http_monitor" "example" {\n  count = (\n    var.enable_dns &&\n    var.enable_monitor &&\n    var.existing_monitor_id == null\n  ) ? 1 : 0\n  display_name = "health"\n}\n'
  with patch.object(coverage,'read_sources',return_value=[('main.tf',src)]):
   entries,lookups,_=coverage.terraform('example')
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp)
   folder=root/'blueprints/example/architecture'
   folder.mkdir(parents=True)
   with patch.object(coverage,'ROOT',root):
    coverage.render_map('example','OCI',entries,lookups,False)
   labels=' '.join(html.unescape(c.get('value','')) for c in ET.parse(folder/'oci-resources.drawio').findall('.//mxCell'))
   self.assertIn('var.enable_dns',labels)
   self.assertIn('var.enable_monitor',labels)
   self.assertIn('var.existing_monitor_id',labels)
   self.assertIn('? 1 : 0',labels)


class CompanionRootTests(unittest.TestCase):
 def test_infrastructure_entry_is_inventoried_and_scoped(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp);gcp=root/'blueprints/example/gcp';gcp.mkdir(parents=True)
   (gcp/'infrastructure.tf').write_text('resource "google_compute_network" "this" {\n  count = var.enabled ? 1 : 0\n  name = "example"\n}\nresource "terraform_data" "guard" {\n  input = true\n}\n')
   with patch.object(coverage,'ROOT',root):
    resources,_,sources=coverage.companion_resources('blueprints/example')
   self.assertEqual({r['address'] for r in resources},{'gcp.google_compute_network.this','gcp.terraform_data.guard'})
   self.assertEqual({r['cloud'] for r in resources},{'GCP','Contracts'})
   self.assertTrue(any(s['path'].endswith('/gcp/infrastructure.tf') for s in sources))

 def test_separate_gcp_input_ids_are_covered(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=Path(tmp);gcp=root/'blueprints/example/gcp';gcp.mkdir(parents=True)
   (gcp/'variables.tf').write_text('variable "project_id" {\n  type = string\n  description = "Existing project"\n}\n')
   with patch.object(coverage,'ROOT',root):
    refs=coverage.input_references('blueprints/example')
   self.assertEqual(refs[0]['address'],'gcp.var.project_id')


if __name__=='__main__':unittest.main()
