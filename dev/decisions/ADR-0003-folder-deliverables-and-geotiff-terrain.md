# ADR-0003: Expose folder deliverables, not raster GeoPackages

- Status: accepted migration design; provider integration pending.
- Date: 2026-09-07
- Refines ADR-0001/0002's local-storage direction without changing the R Provider.

Adopt [the cross-repository decision and evidence](../../../FG-architecture/dev/decisions/adr-0004-folder-based-spatial-deliverables.md):
Reach–Survey–Event folders contain vector/table GeoPackages, external GeoTIFF
terrain and explicit metadata links. Esri supports some raster tiles but is not
assumed to support faithful numerical GeoPackage terrain. Migration must not wait
for a vendor change. Preserve the production ArcGIS toolbox and its archives.

Future wrappers select declared datasets or a folder inventory and pass resolved
artifacts to shared fluvgeo methods. They must not search by DEM filename/year,
assume a GeoPackage contains all event inputs, or implement a competing metadata
resolver. Apply [FGDB's folder requirements](../../../FGDB/dev/schemas/local-project-folder-requirements.md).

The proposed read-only network GeoPackage tool can still review that limited
artifact, but must not claim it has reviewed a complete event delivery. Before
terrain tools ship, qualify external GeoTIFF values, NoData, embedded CRS and
metadata links through the actual R Provider. No tool/profile installation or
data conversion follows from this decision.
