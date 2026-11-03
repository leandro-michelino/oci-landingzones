"""Guard the difference between transport links and internal route annotations."""
import importlib.util
import unittest
from pathlib import Path
from types import SimpleNamespace

spec = importlib.util.spec_from_file_location('connection_review', Path(__file__).with_name('check-connections.py'))
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)


def node(cloud):
    boundary = SimpleNamespace(parent=None, kind='group:region' if cloud == 'OCI' else 'group:thirdparty', label=cloud)
    return SimpleNamespace(parent=boundary, kind='icon', name='Gateway', label='Gateway')


class SeparateTransportPolicy(unittest.TestCase):
    def test_combined_cross_cloud_transport_is_rejected(self):
        d = SimpleNamespace(edge_meta=[{'a': node('OCI'), 'b': node('AWS'), 'label': 'FastConnect or VPN'}])
        with self.assertRaisesRegex(AssertionError, 'separate transport connectors'):
            review.semantic_checks('test/transports', d)

    def test_independent_cross_cloud_transports_are_accepted(self):
        d = SimpleNamespace(edge_meta=[
            {'a': node('OCI'), 'b': node('AWS'), 'label': 'PRIMARY FastConnect + Direct Connect'},
            {'a': node('OCI'), 'b': node('AWS'), 'label': 'OPTIONAL VPN backup'},
        ])
        review.semantic_checks('test/transports', d)

    def test_internal_route_policy_can_describe_both_transports(self):
        d = SimpleNamespace(edge_meta=[{'a': node('OCI'), 'b': node('OCI'), 'label': 'Routes for Interconnect or VPN'}])
        review.semantic_checks('test/transports', d)


if __name__ == '__main__':
    unittest.main()
