# fg-qgis-toolbox

A QGIS toolbox for FluvialGeomorph's developing open-source workflow.

Status: first experimental report wrapper implemented; no QGIS algorithms
deployed and no installation procedure qualified yet.

## Purpose

Develop and test the open-source desktop workflow separately from the existing
production [ArcGIS Pro toolbox](https://github.com/FluvialGeomorph/FluvialGeomorph-toolbox).
This provides room to reorganize tools around study definition, terrain
development, forensic archive reconstruction and FGDB preparation, while the
production workflow continues to operate.

QGIS and Shiny should expose shared scientific capabilities in **fluvgeo**, not
maintain separate scientific implementations. **FGDB** owns governed persistence
and enterprise loading. Local spatial data target qualified **OGC GeoPackage**
storage for vectors/tables; numerical terrain uses external **GeoTIFFs** within
a linked **Reach–Survey–Event folder**. Original archives remain preserved
evidence. See the [folder/terrain decision](dev/decisions/ADR-0003-folder-deliverables-and-geotiff-terrain.md).

The accepted [migration decision](dev/decisions/ADR-0001-parallel-open-source-migration.md)
records ownership, production isolation and incremental verification. Separate
repositories must also use appropriately isolated development runtimes and
reviewed shared-backend versions; production upgrades are not automatic.

## First experimental tool

**Review Stream Network GeoPackage** exposes the existing fluvgeo reader,
validation and Terrain Development report through QGIS:

1. Select an existing fluvgeo network GeoPackage.
2. Inspect its network and findings, retaining explicit missing-context warnings.
3. Generate a new durable HTML report without modifying sources or acceptance.

The packaged script is `fg_review_stream_network.rsx`. It accepts a complete
fluvgeo network bundle and a new HTML destination, not a generic vector layer.
This deliberately limited network-only view does not yet reopen the full saved
Study Area context used by the Cole Creek development demonstration.

The selected integration is the North Road Processing R Provider. Direct-R tests
and actual QGIS 3.44.14/Provider 4.1.0 headless execution now exercise the script.
The R boundary and local PROJ repair are verified; remaining desktop checks
still prevent production deployment qualification. See [behavior](dev/features/review-stream-network.md)
and [QGIS findings](dev/features/qgis-provider-qualification.md).

Version 0.0.0.9001 adds a conservative R runtime guard: recognized OSGeo4W
resource overrides are isolated before backend loading; unfamiliar custom paths
are refused. The guard is tested through the real provider. QGIS's stale PROJ
package data was repaired on 2026-09-09; the real parameter dialog was also
tested offscreen. See the [repair record](dev/workflows/osgeo-proj-repair.md).

## Package foundation

The R package is **fgqgis**; its `.rsx` tools are intended to appear in the
**FluvialGeomorph** group under QGIS's existing **R** Provider. Each tool has
inline help and delegates scientific work to fluvgeo. This is not a new Python
plugin. The [working architecture decision](dev/decisions/ADR-0002-r-package-processing-foundation.md)
records the package, provider and testing choices.

- `inst/rscripts/`: one experimental wrapper, not approved for deployment.
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
