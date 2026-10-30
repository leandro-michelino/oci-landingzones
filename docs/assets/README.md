# Portfolio overview

The main repository README displays `oci-landing-zones-banner.png`.
Its editable source is `oci-landing-zones-banner.drawio`; the SVG is an
alternative export of the same source.

This is a conceptual portfolio map. Grouping describes blueprint families,
not mandatory deployment dependencies or configured cloud connections.

Regenerate all three artifacts with:

```bash
python3 scripts/diagrams/portfolio-overview.py
```

Requires the OCI architecture diagram skill, its official Oracle toolkit and
the draw.io desktop exporter. Set `OCI_DIAGRAM_SKILL` if the skill is installed
outside `~/.codex/skills/oci-architecture-diagrams`.

Validation on October 30, 2026: the skill's layout check passed without warnings;
the PNG was exported and visually inspected; draw.io/SVG XML and README asset
links passed local checks. These are documentation checks only.
