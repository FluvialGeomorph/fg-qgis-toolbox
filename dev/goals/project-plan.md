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
environment. Actual QGIS 3.44.14/R Provider 4.1.0 headless execution now works,
but exposed spatial-environment conflicts and noisy provider failure handling.
See the [qualification record](../features/qgis-provider-qualification.md).
The packaged R subprocess guard now implements the recognized-OSGeo4W boundary.
The controlled local PROJ package-data repair completed on 2026-09-09; actual
provider tests pass afterwards, and the Qt parameter dialog was tested offscreen.
See the [repair record](../workflows/osgeo-proj-repair.md). Next complete an
analyst-run interactive trial in an isolated QGIS 3.44 profile, including file
selection, report opening and cancellation. Do not configure a production profile
or alter other shared packages without reviewed scope. Missing Study
Area context remains visible in this network-only tool.

Success requires direct-R agreement **and** actual provider execution, useful
inline help, explicit failures and unchanged source evidence. Package tests alone
do not authorize promotion. Do not expand into terrain extraction, archive-wide
migration or enterprise loading as part of that first wrapper.
