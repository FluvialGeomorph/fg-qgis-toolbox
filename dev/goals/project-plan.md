# Project plan

## Outcome

Provide an incremental, open-source QGIS desktop workflow using the same fluvgeo
science as Shiny. Support Study Area configuration and description, terrain
development, forensic reconstruction of archived projects, and eventual FGDB
preparation without replacing production ArcGIS prematurely.

## Current scope

Package and AI-assisted development foundations before functionality deployment:
usethis package scaffold, reproducibleai context, `.rsx` authoring rules, testthis
wrapper tests using fluvgeodata, and an upstream provider compliance review.

## Next bounded milestone

Implement and qualify the previously proposed **Review Stream Network
GeoPackage** wrapper: read an existing governed bundle, show findings and produce
a new Terrain Development report. First inspect the actual QGIS/R Provider
environment and define the input/output boundary; do not silently configure a
production profile. Missing Study Area context must remain visible.

Success requires direct-R agreement **and** actual provider execution, useful
inline help, explicit failures and unchanged source evidence. Package tests alone
do not authorize promotion. Do not expand into terrain extraction, archive-wide
migration or enterprise loading as part of that first wrapper.
