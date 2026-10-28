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

The GCP Partner Interconnect blueprint now declares Google Cloud resources.
Its diagrams use the verified Cloud Network, Cloud Router, Partner Interconnect
and Cloud Firewall Rules stencils. Named boxes retain unmapped subnet, router
interface and peer types. No live GCP deployment is implied.

The Azure AI gateway additionally uses unmodified `Azure_OpenAI.svg` from
`azure2/ai_machine_learning/` and `API_Management_Services.svg` from
`azure2/integration/`, extracted from the same installed draw.io 32.6.1 bundle.
The current CognitiveServices account declaration has kind OpenAI; its optional
model deployment remains an explicitly named child resource without a substitute icon.

AKS diagrams use unmodified `Kubernetes_Services.svg` from the installed
`azure2/containers/` library. EKS uses the bundled `mxgraph.aws4.eks` stencil.
Managed node groups remain explicitly named boxes; cluster glyphs are not
substituted for node-group resources. Both mappings identify declared clusters
and do not assert version availability or cluster readiness.

VMware hybrid diagrams use unmodified `AVS.svg` from `azure2/azure_vmware_solution/`
and `ExpressRoute_Circuits.svg` from `azure2/networking/` in the same draw.io
32.6.1 bundle. HCX, VMware components and Global Reach associations retain
named boxes where there is no exact resource glyph.

The installed draw.io `vvd.xml` library contains the exact `vcenter server`,
`nsx manager` and `virtual machine` stencils, used as `mxgraph.vvd.vcenter_server`,
`mxgraph.vvd.nsx_manager` and `mxgraph.vvd.virtual_machine`. These identify their
VMware components; they are not substitutes for a dedicated OCVS service icon.
No OCVS-specific stencil was found in the installed library or OCI Toolkit v24.2.
