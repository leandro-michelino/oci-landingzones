# Provider Icon Sources

OCI diagrams continue to use Oracle's official Architecture Diagram Toolkit v24.2
through the installed `oci-architecture-diagrams` skill. External cloud resources
use the respective provider's icon vocabulary from draw.io, as requested.

- Azure SVGs in `azure/` preserve unmodified icon artwork from draw.io Desktop 32.6.1,
  `drawio/src/main/webapp/img/lib/azure2/`. They are embedded into generated
  draw.io files as SVG data URLs so PNG export needs no remote image request.
- AWS icons use the bundled `mxgraph.aws4` library. GCP mappings use
  `mxgraph.gcp2`. `cloud-icons.py` records exact resource-to-icon mappings.
- Provider names, marks and artwork remain the property of their respective
  owners. Icons identify architecture components; they do not imply endorsement.
- An association, metadata contract or resource without a mapped icon remains
  explicitly labelled. A service icon on a grouped overview card represents that
  service; resource-detail cards retain exact source resource types and names.

Upstream library and provider guidance:

- [draw.io shapes and stencils](https://github.com/jgraph/drawio/wiki/Shapes-and-Stencils)
- [Azure assets in draw.io](https://github.com/jgraph/drawio/tree/dev/src/main/webapp/img/lib/azure2)
- [Microsoft Azure architecture icons](https://learn.microsoft.com/azure/architecture/icons/)
- [AWS architecture icons](https://aws.amazon.com/architecture/icons/)
- [Google Cloud icons](https://cloud.google.com/icons)

No GCP resource definitions exist in the current blueprint sources. GCP mappings
are available for future diagrams; no GCP deployment is implied.
