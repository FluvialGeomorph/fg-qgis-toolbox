# Project plan

## Outcome

Provide an incremental, open-source QGIS desktop workflow using the same fluvgeo
science as Shiny. Support Study Area configuration and description, terrain
development, forensic reconstruction of archived projects, and eventual FGDB
preparation without replacing production ArcGIS prematurely.

## Current scope

Package and AI-assisted foundations are implemented. The first experimental
network-review wrapper now delegates to the fluvgeo Terrain Development report.
The actual QGIS R Provider can invoke fluvgeo and produce a report whose tables
agree with direct R, without changing source data. The observed environment
conflicts have been addressed. This establishes a working connection for one
read-only tool, not complete interoperability. See the
[qualification summary](../features/qgis-provider-qualification.md).

## Next bounded milestone

Complete an **analyst-run trial in an isolated QGIS 3.44 profile**: select the
network file and a persistent report destination, run the tool, open the report,
and check cancellation and child-process cleanup. Offscreen dialog inspection
has passed but does not replace this interaction. Record actionable usability
issues and failures before adding more tools. Do not configure a production
profile or upgrade shared packages as a side effect.

Success requires direct-R agreement **and** actual provider execution, useful
inline help, explicit failures and unchanged source evidence. Package tests alone
do not authorize promotion. Do not expand into terrain extraction, archive-wide
migration or enterprise loading as part of that first wrapper.

## How this advances the larger workflow

The tool accepts only a network bundle: it cannot reopen the full Study Area,
event inventory or terrain links from that file. Missing context remains visible.
After the desktop trial, use its feedback and the
[fluvgeo plan](../../../fluvgeo/dev/goals/project-plan.md) to select the next
study-context capability. Complete folder binding, broader client qualification
and deployment remain separate work. The accepted GeoPackage-vector/GeoTIFF-terrain
folder design is unchanged; runtime maintenance is not an ongoing research goal.
