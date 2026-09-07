# QGIS R boundary and upstream review

Reviewed 2026-09-07. Evidence below describes upstream behavior, not a verified
local QGIS installation. Working choices are recorded in ADR-0002.

## Division of labor

| Owner | Responsibility |
| --- | --- |
| North Road R Provider | QGIS registration, parameter widgets, R subprocess and output transport. |
| fgqgis | Packaged `.rsx` adapters, inline help, boundary tests and discoverable assets. |
| fluvgeo | Scientific methods, validation, structured findings and durable reports. |
| fluvgeodata | Retained test inputs; do not edit fixtures during tests. |
| FGDB | Governed hierarchy, persistence and loading, not implicit wrapper-side acceptance. |

Shiny continues to call fluvgeo without requiring QGIS. Preserve the separate
production ArcGIS path and its runtime. Study Area reporting must support new
study configuration, durable description, and forensic archive reconstruction;
QGIS supplies desktop interaction, not a separate report implementation.

## Verified upstream conventions

- Scripts declare metadata with `##`; the provider supports stable names,
  separate display names, groups, and typed inputs/outputs. Prefer explicit
  GeoPackage **file** inputs for multi-layer governed bundles: a generic vector
  layer is not a bundle. [Script syntax](https://north-road.github.io/qgis-processing-r/script-syntax/).
- Inline help uses `#' KEY: description`, including `ALG_DESC`, `ALG_VERSION`
  and parameter names; multiline continuation is supported. It has been
  available since plugin 3.2.0. Do not maintain duplicate `.rsx.help` files.
  [Help syntax](https://north-road.github.io/qgis-processing-r/help-syntax/).
- Current plugin guidance uses `sf` for vectors and `raster` for automatic
  raster transport. Legacy `rgdal` directives are obsolete. terra-aware backend
  operations therefore need an explicitly qualified file boundary or conversion,
  not an assumed automatic terra handoff.
  [Provider guidance](https://north-road.github.io/qgis-processing-r/).
- The implementation identifies itself as `r`, recursively scans configured
  script folders, defaults spatial outputs to GeoPackage, and offers an R
  library-folder setting. **Never point it at the repository root**, where it
  would find test fixtures. Installing an R package alone does not register its
  scripts. [Provider source](https://github.com/north-road/qgis-processing-r/blob/master/processing_r/processing/provider.py).

## QGIS best practices: application and limits

QGIS recommends declared outputs, informative failures, noninteractive execution,
progress/cancellation handling, and documented parameters. These requirements
also frame our wrappers, but Python API examples are not directly callable from
R. Validate the provider's behavior instead of claiming parity from R tests.
[Processing best practices](https://docs.qgis.org/3.44/en/docs/user_manual/processing/scripts.html#best-practices-for-writing-script-algorithms).

This is an R script collection using an existing plugin, not a custom Python
Processing plugin. A new provider class, `metadata.txt`, plugin zip and separate
plugin publication are outside this architecture.
[Custom Processing plugin guide](https://docs.qgis.org/3.44/en/docs/pyqgis_developer_cookbook/processing.html).

## Qualification still required before first deployment

[ADR-0003](../decisions/ADR-0003-folder-deliverables-and-geotiff-terrain.md) sets
the local delivery boundary: Reach–Survey–Event folders, vector/table GeoPackages,
external GeoTIFF terrain and explicit metadata links. Do not promote the earlier
GDAL raster-GeoPackage experiment as the cross-client terrain format. QGIS's own
ability to read it would not establish ArcGIS interoperability.

- Record the actual QGIS, R Provider, R, fluvgeo, sf/terra and GDAL/PROJ versions;
  select an isolated QGIS profile and R library. No supported matrix exists yet.
- Test registration, displayed help, native parameter conversion, actual outputs,
  batch/headless execution, missing dependencies, invalid input and cancellation.
- Verify spaces/non-ASCII paths, layer selection, overwrite refusal, source
  preservation, partial-output handling, locks and cleanup across processes.
- Compare backend results and storage round trips: CRS semantics and units,
  coordinates/dimensions, attribute types/nulls/IDs; raster NoData, resolution,
  alignment and vertical references when raster tools are introduced.
- Use the dedicated fluvgeo GeoPackage writer for governed network bundles;
  provider-generated vector GeoPackages alone do not prove FGDB readiness.
- Prove required scientific methods can run without ArcGIS. A thin R wrapper
  is not evidence that all fluvgeo dependencies are already open-source-only.

Inference: this reuse should reduce bridge maintenance. Unknown: the operational
quality of the local provider/backend combination until those tests run.
