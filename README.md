# fg-qgis-toolbox

A QGIS toolbox for FluvialGeomorph's developing open-source workflow.

Status: experimental network/report and bounded Study Area editing wrappers
implemented; no production deployment or qualified installation procedure yet.

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

**Review Saved Study Area** now opens a separate context GeoPackage containing
the supplied hierarchy, event inventory, notes and links to the network and terrain
manifest. It regenerates the same report without rerunning the demonstration's
setup script. Keep the whole linked folder together; missing evidence remains
visible. See [the tool contract](dev/features/review-study-area.md).

The Cole Creek desktop trial is complete: the analyst found the workflow clear,
the 19 report tables matched direct R, and source hashes were unchanged. This
qualifies the bounded trial, not a production installation.

**Revise Study Area Details** adds the first small editing step: change a supplied
Study Area's display name and/or append a scope note, save a new context beside
the original and refresh the report. Blank fields keep current values. This does
not edit hierarchy identities, geometry or terrain selections. Free-text transport
requires the development provider correction described in
[the editing record](dev/features/review-study-area.md#bounded-editing-step-2026-09-10);
the new form is not yet analyst-qualified or deployed.

## What the first test tells us

The question was whether QGIS can be the desktop interface to our existing R
science, without duplicating it. **For this one read-only tool, yes:** the actual
North Road R Provider generated the report, its tables agreed with direct R,
and the source stayed unchanged. Two environment conflicts were addressed;
they were not GeoPackage format failures or changes to the scientific methods.

The cancellation candidate passed eight regression cases, the real report
comparison and the analyst's desktop confirmation. The
[maintenance review](dev/patches/r-provider-cancellation/README.md#maintenance-review-2026-09-09)
recommends contributing evidence upstream while retaining the isolated development
candidate; the contribution draft is not published. Saved Study Area reopening is
the new bounded capability described above. Production adoption remains a
separate decision. The
official plugin and original trial profile remain unchanged. See the
[desktop confirmation](dev/features/qgis-provider-qualification.md#desktop-cancellation-confirmation-2026-09-09).
This is not yet a production release
or proof of complete Study Area, vector/raster or FGDB interoperability.
Read [the current plan](dev/goals/project-plan.md) for scope,
[the qualification summary](dev/features/qgis-provider-qualification.md) for
what passed and what remains, and [the tool contract](dev/features/review-stream-network.md)
for exact behavior. The installation repair is supporting evidence linked there.

## Package foundation

The R package is **fgqgis**; its `.rsx` tools are intended to appear in the
**FluvialGeomorph** group under QGIS's existing **R** Provider. Each tool has
inline help and delegates scientific work to fluvgeo. This is not a new Python
plugin. The [working architecture decision](dev/decisions/ADR-0002-r-package-processing-foundation.md)
records the package, provider and testing choices.

- `inst/rscripts/`: three experimental wrappers, not approved for deployment.
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
