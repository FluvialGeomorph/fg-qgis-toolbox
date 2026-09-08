# Project plan

## Outcome

Provide an incremental, open-source QGIS desktop workflow using the same fluvgeo
science as Shiny. Support Study Area configuration and description, terrain
development, forensic reconstruction of archived projects, and eventual FGDB
preparation without replacing production ArcGIS prematurely.

## Current scope

Package and AI-assisted foundations are implemented. The first experimental
network-review wrapper now delegates to the fluvgeo Terrain Development report.
Its [feature record](../features/review-stream-network.md) separates direct-R
verification from outstanding QGIS qualification.

## Next bounded milestone

Qualify **Review Stream Network GeoPackage** in an actual QGIS/R Provider
environment. Standard installation/profile discovery found no usable runtime on
2026-09-08; an existing portable/custom installation remains unknown. Obtain the
runtime location or a reviewed isolated installation before proceeding. Do not
silently configure a production profile. Missing Study Area context remains
visible in this network-only tool.

Success requires direct-R agreement **and** actual provider execution, useful
inline help, explicit failures and unchanged source evidence. Package tests alone
do not authorize promotion. Do not expand into terrain extraction, archive-wide
migration or enterprise loading as part of that first wrapper.
