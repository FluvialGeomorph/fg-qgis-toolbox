# fg-qgis-toolbox

A QGIS toolbox for FluvialGeomorph's developing open-source workflow.

Status: R package and development/test foundations implemented; no user-facing
QGIS algorithms deployed and no installation procedure qualified yet.

## Purpose

Develop and test the open-source desktop workflow separately from the existing
production [ArcGIS Pro toolbox](https://github.com/FluvialGeomorph/FluvialGeomorph-toolbox).
This provides room to reorganize tools around study definition, terrain
development, forensic archive reconstruction and FGDB preparation, while the
production workflow continues to operate.

QGIS and Shiny should expose shared scientific capabilities in **fluvgeo**, not
maintain separate scientific implementations. **FGDB** owns governed persistence
and enterprise loading. Local spatial data target qualified **OGC GeoPackage**
storage; original archives remain preserved evidence.

The accepted [migration decision](dev/decisions/ADR-0001-parallel-open-source-migration.md)
records ownership, production isolation and incremental verification. Separate
repositories must also use appropriately isolated development runtimes and
reviewed shared-backend versions; production upgrades are not automatic.

## First proposed tool

**Review Stream Network GeoPackage** would expose the existing fluvgeo reader,
validation and Terrain Development report through QGIS:

1. Select an existing fluvgeo network GeoPackage.
2. Inspect its network and findings, retaining explicit missing-context warnings.
3. Generate a new durable HTML report without modifying sources or acceptance.

The selected integration is the North Road Processing R Provider. First inspect
the installed QGIS/R Provider/R environment. Then verify the tool end to end on a known fixture, including failure
handling, unchanged source data and agreement with direct-R results. This
bounded first tool can proceed while project-context storage is being designed.

## Package foundation

The R package is **fgqgis**; its future `.rsx` tools will appear in the
**FluvialGeomorph** group under QGIS's existing **R** Provider. Each tool has
inline help and delegates scientific work to fluvgeo. This is not a new Python
plugin. The [working architecture decision](dev/decisions/ADR-0002-r-package-processing-foundation.md)
records the package, provider and testing choices.

- `inst/rscripts/`: future deployable wrappers, currently none.
- `R/` and `man/`: documented package support; `qgis_scripts()` locates assets
  without installing or configuring anything.
- `tests/testthat/`: fast package tests and a separate testthis wrapper suite
  using retained Cole Creek data from fluvgeodata.
- `dev/`: reproducibleai's base/R-package context, decisions and workflows.

See [development/testing](dev/workflows/qgis-package-development.md) and the
[QGIS boundary review](dev/architecture/qgis-r-boundary.md). Do not point QGIS at
the repository root: recursive discovery would expose test fixtures.

No supported-version matrix, production upgrade, Shiny deployment or FGDB loader
is implied by this foundation.
