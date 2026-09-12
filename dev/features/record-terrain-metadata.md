# Record Terrain Metadata

## Outcome

The thin QGIS tool calls `fluvgeo::record_study_terrain_metadata()` to fill
previously unknown elevation units and/or vertical reference for a selected
event terrain file. It saves a new manifest, context and Define Study Area report.
The same ordinary R API is available to future Shiny orchestration.

An analyst supplies evidence and attribution. Either vertical field may remain
blank/unknown; at least one new field must be supplied. Known assertions cannot
be replaced by this initial-entry tool. File-level assertions apply to all events
sharing that artifact. Previous evidence is retained, with an appended timestamp,
analyst and new evidence text. Recorded assertions are not independently verified.
No datum is inferred from a filename, horizontal CRS, apparent elevations or year.

## Boundaries

No raster values, masks, embedded CRS, stored observations, file fingerprints,
event identities or associations are edited. New metadata is checked against any
exposed raster band unit; conflicts are refused. Existing selected-file integrity
conflicts are refused, not refreshed away. Unrelated findings remain visible.
Output collisions are refused. Manifests stay beside their predecessors; contexts
stay beside their predecessors. A late failure may leave earlier published
outputs, which should be retained and reviewed. No concurrent input editing.

Uses existing terrain-intake schema fields, with additive `metadata_evidence`
in the inspection table so reports retain the supplied basis. No new FGDB schema,
acquisition identity, generic correction interface, conversion, vertical
transformation or scientific acceptance state is introduced.

The [coverage-percentage experiment](terrain-coverage-review.md) is withdrawn.
Intentional NoData/AOI masks are processing decisions, not generic missing-data
findings. No full-array scan or rectangle-occupancy metric is added here.

## Verification and deployment boundary

Focused tests cover partial metadata, shared files, preservation, remaining
unknowns, attributed evidence, refusal of replacements/changed files, and removal
of coverage reporting. Wrapper tests use retained Cole Creek rasters with explicitly
synthetic metadata, not asserted source datums. Actual-provider qualification uses
copied inputs and the existing isolated provider. The cleaned Cole Creek report
must keep its actual vertical metadata unknown until source evidence is supplied.

fluvgeo owns logic/reporting; fgqgis owns the thin form. ArcGIS toolbox, ohwm2,
RegionalCurve, archive data, production libraries and installed profiles are
unchanged. Development versions: fluvgeo 2026.09.11.9008 and fgqgis 0.0.0.9013.

## Reproduce the bounded qualification

Run `prepare-terrain-metadata-check.R` with a new output root and the preceding
linked Cole Creek context. It installs isolated development packages and copies
the linked folder without refreshing observations. `define-study-area.html` at
the root is the cleaned real-context report; its unknown metadata is preserved.
A separate `fixtures/synthetic.gpkg` labels the transport test unambiguously.

Run `qualify-qgis-provider.py --terrain-metadata-context` with that synthetic
context, the isolated library and the previously qualified provider. Use a separate
`--inspect-dialog-only` root for the actual Qt form. Tests compare saved records
and report tables to direct R, normalizing only assertion timestamps. Source,
copied-input, identity, link and prior-artifact preservation are checked.
Evidence for this increment is ignored under `dev/check-output/terrain-metadata-v1/`.

The next domain step is to obtain actual source evidence for any Cole Creek
vertical assertions, not force entries to clear report findings. Other study
configuration can continue while those values remain unknown. General correction
of already-known assertions and scientific comparison workflows remain separate.

## Verified development results (2026-09-11)

- The focused backend/context/report suite passes, including 37 new metadata
  assertions. The first run exposed a fixed-column-name assumption in the legacy
  Terrain Development template when metadata evidence was added; keyed labels
  now support both old and extended inventories, and the full focused rerun passes.
- Explicit testthis wrappers pass 204 assertions and fast package tests pass 183,
  with no assertion failures, warnings or skips. Generated help was refreshed.
- QGIS 3.44.14 / R Provider 4.1.0-fg-text1 registers `r:fgrecordterrainmetadata`
  and no longer discovers the withdrawn coverage tool in the new isolated library.
  All nine form fields round-trip (including a blank optional field); its screenshot
  was inspected. All four execution/refusal cases pass. Direct R matches saved
  manifest content and report tables apart from assertion timestamps; prior
  identities, associations, other artifacts, observations and hashes are retained.
  No analyst usability trial is inferred from this offscreen developer check.
- The regenerated real Cole Creek report contains no coverage chart/percentages.
  Its actual vertical metadata remains unknown. Synthetic metadata is confined
  to explicitly labeled, copied qualification inputs. Old experiment reports and
  isolated package snapshots remain retained development evidence, not current
  outputs. Only the retired implementation/tool/test scripts were removed.
- Final native source checks finish with fgqgis `Status: OK` and fluvgeo
  `Status: 2 NOTEs` (existing undeclared `methods` use and package-wide globals/
  imports). Manuals/vignettes are excluded; fluvgeo full tests/examples are
  excluded and its check lacks suggested fluvgeodata. The focused workspace and
  wrapper tests above use retained data. Network-index and Windows `du` messages
  remain environmental limits, as do R 4.6.1-built package startup warnings on the
  registry-selected R 4.6.0. No package-check errors or warnings remain.
- Strict reproducibleai validation passes in both repositories with five existing
  seeded-content customization notices. Changes remain uncommitted alongside
  preceding increments; no archive or production deployment changes were made.

## Real-source metadata review (2026-09-12)

The next planned step was to use actual Cole Creek metadata. Read-only GDAL
inspection of `GDB_Items.Definition` and `GDB_Items.Documentation` for the three
selected rasters recovered embedded Esri processing histories, not just the
exported GeoTIFF headers. Sources were `y2006_R1.gdb / dem_2006_ft_50`,
`y2010_R1.gdb / dem_2010_ft_50` and `y2016_R1.gdb / dem_2016_hydro_50`
at fluvgeodata commit `25b562d9cbfca4f841aad097e246981322466f5f`.

The recorded `Clip` operations use `ClippingGeometry`, supporting the analyst's
description of deliberate AOI masking. No percentage or missing-data finding is
derived from that history. The displayed metre unit belongs to the horizontal
CRS, not an established elevation unit. No explicit elevation-unit or vertical-
datum declaration was identified in these records or the fixture storage notes.
Names containing `ft` remain clues, not populated assertions.

The 2006 history references an upstream raster named `LittlePapillionCreek_2004_ft`.
This is a lineage ambiguity, not proof that the user-confirmed Survey Event year
is wrong. Preserve the 2006 event and ask the analyst before reconciling acquisition
versus source-product dates. Do not copy workstation/account paths from embedded
history into maintained documentation.

No metadata assertions, acquisition records, reports or source data were changed
by this review. Actual elevation units/reference now require analyst confirmation
or additional source documentation before exercising the entry tool on real data.
Other toolbox development is not technically blocked by those unknowns, but
substituting another milestone should be an explicit next choice rather than
inventing metadata to claim this one complete.

## Owner clarification (2026-09-12)

The project owner clarifies the elevation convention as **"feet"**, selected during
ArcMap/ArcGIS Pro raster work, with special-case exceptions. This correction
supersedes the earlier wording "US feet"; FG did not specifically require U.S.
survey feet. This is attributed domain evidence, not a newly discovered embedded
raster declaration. Do not propagate the convention without evidence to
exceptional or unrelated data.

Preserve the corrected wording. The [ArcGIS unit investigation](../../../FGDB/dev/architecture/legacy-esri-elevation-feet.md)
finds international-foot factors in historic FG slope code and Esri raster
guidance, but different semantics for generic geoprocessing distance keywords.
The owner subsequently recalls using Raster Calculator with 0.3048 after deriving
a DEM from meter-valued point clouds. Meter values divided by 0.3048 produce
international feet; this is now the supported interpretation of that recalled
workflow, not independently verified processing history for every project.
Vertical datum and
the 2004/2006 source/acquisition relationship also remain unresolved. None can be
inferred from horizontal metres or the feet convention. This documentation update
does not modify saved manifests, reports, rasters or Survey Event records; the
existing generated report therefore still shows its earlier unknown metadata.

The owner commits vertical reference, source provenance and analysis-variable
units to upcoming development cycles. Follow the
[scientific traceability roadmap](../../../FGDB/dev/goals/scientific-traceability-roadmap.md),
keeping scientific logic in fluvgeo and forms here thin. Continue bounded toolbox
work without turning the whole overhaul into a prerequisite or filling unknowns
merely to clear report findings.
