# OCI private DNS module

Creates optional private views/zones, manages selected VCN resolver associations and optionally creates listening/forwarding endpoints. Networks, subnets, IAM and remote DNS services are caller prerequisites. This module does not create cross-cloud transport.

Forwarding rules reference endpoints by a string name. Resolver updates explicitly depend on this module's endpoint resources so the API cannot receive a forwarding rule before its source endpoint exists; destroy reverses that order. Two local mocked plan cases cover disabled DNS and an endpoint/rule created together. This is dependency/schema evidence, not DNS query or network reachability evidence.

Wrappers pinned to an earlier module commit retain that exact implementation. This working-tree correction applies when calling this module at a revision containing it; existing DNS wrappers do not expose endpoint creation and were not silently repinned. Review state and resolver ownership before adopting a new revision: managing `attached_views` and `rules` can replace configurations owned elsewhere.

Validation details: [networking review](../../../docs/NETWORKING-REVIEW-20261103.md).
