"""Regression checks for diagram inventories; no Terraform or cloud execution."""
import importlib.util
from pathlib import Path
import unittest
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


if __name__=='__main__':unittest.main()
