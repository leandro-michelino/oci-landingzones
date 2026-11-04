# Portfolio overview

The main repository README displays `oci-landing-zones-banner.png`.
The SVG is an alternative image export. Banners and presentation graphics
publish image files only; editable intermediates are not stored or linked
in the repository.

This is a conceptual portfolio map. Grouping describes blueprint families,
not mandatory deployment dependencies or configured cloud connections.

Regenerate the two image exports with:

```bash
python3 scripts/diagrams/portfolio-overview.py
```

The authoring generator creates its draw.io intermediate in a temporary
directory and removes it after exporting the PNG and SVG. Full catalog
regeneration follows the same publication policy. Architecture overviews
and their detail/input pages retain their editable files.

Requires the OCI architecture diagram skill, its official Oracle toolkit and
the draw.io desktop exporter. Set `OCI_DIAGRAM_SKILL` if the skill is installed
outside `~/.codex/skills/oci-architecture-diagrams`.

## Publication review — 2026-11-04

The repository scan found one presentation editable (the portfolio banner)
and 348 architecture overview/detail/reference documents. Removed the banner
editable and its README download link. No other banner or presentation
editable was found. The 348 architecture documents remain published.

Validation: the banner generator and its temporary-source export passed;
PNG pixels and SVG content match the prior published images. Temporary
source cleanup, layout, SVG XML, asset links, architecture/source connector
checks and repository documentation contracts passed. No infrastructure
source or cloud validation result changed.
