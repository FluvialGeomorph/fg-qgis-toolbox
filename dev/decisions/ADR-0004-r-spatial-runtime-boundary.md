# ADR-0004: Keep QGIS's spatial resources out of R's runtime

- Status: implemented working boundary; desktop promotion pending.
- Date: 2026-09-08

## Context

Actual QGIS/R Provider execution verified the report integration but exposed
OSGeo4W GDAL driver settings inherited by R's independently bundled GDAL.
The user authorized proceeding with a clear next implementation step after
reviewing the findings. This boundary is client orchestration, not fluvgeo
science and not a reason to implement a replacement Processing provider.

## Decision

The packaged `.rsx` calls `fgqgis::with_qgis_spatial_environment()` before loading
fluvgeo. In a fresh R Provider subprocess, the helper temporarily removes
GDAL_DRIVER_PATH, GDAL_DATA, PROJ_LIB and PROJ_DATA only when every active path
resolves within the identified OSGEO4W_ROOT. It reports variable names, not values.
Unknown/custom/mixed paths are refused without changing the environment.
Isolation is also refused if spatial namespaces are already loaded. With no
active overrides it simply evaluates the backend call.

On success or error after isolation, prior environment values are restored.
No shared settings, files, CRS definitions or spatial namespaces are modified
or reset. This is intended for dedicated provider subprocesses, not switching
between GDAL/PROJ stacks in a long-running session. The script retains
`dont_load_any_packages`; a compatible installed fgqgis is now required as
well as fluvgeo. No automatic package installation is introduced.

## Consequences

The tested Windows OSGeo4W case has a small reusable adapter boundary shared by
future tools. Shiny and direct fluvgeo callers do not inherit a QGIS dependency.
Custom driver/grid paths require separate qualification rather than silent loss.
The guard does not change PATH/DLL loading, qualify every packaging platform,
or promise that arbitrary preinitialized native library state is safe.

QGIS's own stale PROJ database remains a separate installation issue; this guard
cannot repair it. The upstream provider's secondary failure traceback also
remains. Use the [qualification record](../features/qgis-provider-qualification.md)
for verified behavior and outstanding desktop/deployment checks.

Update 2026-09-09: the separate local package-data repair is now complete;
see the [maintenance record](../workflows/osgeo-proj-repair.md). This does not
change the R isolation decision or constitute broad desktop deployment approval.
