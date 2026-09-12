# Working `.rsx` wrapper contract

- One user-facing algorithm per `inst/rscripts/<stable_id>.rsx`.
- Use a stable lowercase `fg_`-prefixed name, a separate human-facing display
  name and `##FluvialGeomorph=group`. Avoid renaming IDs after publication.
  Provider 4.1.0 strips underscores when registering names: the current
  `fg_review_stream_network` declaration becomes `r:fgreviewstreamnetwork`.
  The saved-context tool is registered as `r:fgreviewstudyarea`.
  The bounded editor is `r:fgrevisestudyarea`; its parameters are `INPUT`,
  `NEW_NAME`, `ADD_NOTE`, `CONTEXT` and `OUTPUT`. Optional multiline strings use
  `optional string long` in the qualified QGIS parser, not `longstring`.
  Verify actual IDs through the registry before documenting batch calls.
- The developing saved-context reviewer/editor adds `REPORT_VIEW`: enum values
  0 Terrain Development, 1 Define Study Area, 2 Staging Report. Use the explicit
  trailing default in `enum Terrain Development;Define Study Area;Staging Report 0`.
  QGIS's own `asScriptCode()` emits this form; without that default the observed
  parser consumed the final word of the last multiword option. Assert full option
  labels and default in actual-provider checks. The provider's [enum syntax](https://north-road.github.io/qgis-processing-r/script-syntax/#enum)
  documents zero-based numeric transport. This selection is not a saved schema
  field or acceptance action; no neutral Study Area view is implied.
- The new `fg_start_study_area` declaration accepts `STUDY_NAME`, optional
  multiline `SCOPE_NOTES`, `CONTEXT` and `OUTPUT`. It has no source-input file;
  a new-study draft needs no acquired data. Actual registry ID `r:fgstartstudyarea`
  and the four-parameter form passed qualification on 2026-09-11, separately from
  wrapper-body tests; analyst usability remains a separate trial.
- Declare every parameter/output through provider metadata. Prefer `INPUT` and
  `OUTPUT` for primary parameters in new tools; additional names describe roles.
- Document each parameter/output inline with `#' KEY: text`, plus `ALG_DESC`
  and `ALG_VERSION`. Explain units, required CRS/geometry, source modification,
  output ownership, missing-context limitations and consequential analyst input.
- Delegate scientific decisions to explicit `fluvgeo::` calls. Adapter code may
  validate transport, map parameters and expose results, not reimplement science.
- No interactive prompts, hard-coded workstation paths, global working-directory
  changes, runtime package installation or hidden acceptance/repair.
- Write only declared, user-selected or test-owned outputs. Preserve archives;
  fail visibly on invalid inputs and unsafe destinations. No blanket error
  suppression, silent reprojection, or implied FGDB readiness from file creation.
- Free-text adapters need exact transport checks, including literal backslashes,
  quotes, Unicode and newlines. The 4.1.0 scalar-string serializer can silently
  reinterpret backslashes as R escapes; sourcing `.rsx` in R cannot expose that
  defect. Use the qualified development text correction for the new editor;
  see [the evidence and boundary](../features/review-study-area.md#bounded-editing-step-2026-09-10).
- Treat a Reach–Survey–Event folder as a linked delivery, not a single GeoPackage.
  Terrain payloads are external GeoTIFFs; metadata resolution and validation
  belong in fluvgeo. Follow [ADR-0003](../decisions/ADR-0003-folder-deliverables-and-geotiff-terrain.md).
- Keep the initial body ordinary R; metadata/help are comments. Provider-specific
  executable syntax such as `>` needs actual provider tests before adoption.
- For the OSGeo4W boundary, call `fgqgis::with_qgis_spatial_environment()` before
  loading the scientific backend and retain `dont_load_any_packages`. Do not
  duplicate its checks in each script or blanket-clear arbitrary user paths.
  See [ADR-0004](../decisions/ADR-0004-r-spatial-runtime-boundary.md).

`tests/testthat/helper-rsx.R` checks a subset of these conventions. It is not a
complete parser or proof of architectural compliance; review handles ownership
and scientific meaning. Tests must exercise actual script bodies. Test-only
scripts stay under `tests/testthat/fixtures/`, never `inst/rscripts/`.

## Explicit boundary import

`fg_set_study_boundary.rsx` declares INPUT/BOUNDARY as GeoPackage files, a required
BOUNDARY_LAYER string, multiline RATIONALE and CONTEXT/OUTPUT destinations. It
reads the exact whole layer through sf only after the packaged spatial guard;
it does not use the current QGIS selection or automatic provider vector loading.
Geometry requirements and revision behavior belong in fluvgeo. This bounded file
interface requires one deliberately prepared polygon/multipart feature; it is
not a new standard requiring every study to originate from a particular polygon
dataset. See [the feature contract](../features/set-study-area-boundary.md).

## Initial Stream definition

`fg_define_study_streams.rsx` accepts INPUT, optional multiline STREAM_NAMES,
optional GeoPackage STREAM_SOURCE, SOURCE_LAYER and NAME_FIELD, required multiline
RATIONALE, CONTEXT and OUTPUT. Require either names-only or a complete source
selection, never both. Plain newline parsing is transport; names, geometry,
identity generation and initial-only restrictions belong to fluvgeo. Read sources
inside the spatial guard, not through automatic provider vector conversion.
See [the initial Stream contract](../features/define-study-streams.md).

## Progressive Reach addition

`fg_add_study_reaches.rsx` accepts INPUT, optional STREAM_NAME and multiline
REACH_NAMES, optional GeoPackage REACH_SOURCE with SOURCE_LAYER, NAME_FIELD and
PARENT_FIELD, required multiline RATIONALE, CONTEXT and OUTPUT. Choose names-only
under one exact existing Stream name, or a complete source selection whose parent
field contains exact existing Stream names. fluvgeo owns parent resolution,
name uniqueness within parents, new IDs, optional polygon validation and safe
addition. Existing IDs are preserved; source IDs are not adopted. See
[the additive contract](../features/add-study-reaches.md).

## Existing Reach areas

`fg_set_reach_areas.rsx` reads INPUT and prepared AREAS GeoPackages, exact AREA_LAYER
and ID_FIELD, required multiline RATIONALE, CONTEXT and OUTPUT. ID_FIELD contains
exact saved Reach UUIDs, not source identities to reconcile. Read the whole layer
inside the spatial guard; fluvgeo owns matching, geometry and revision checks.
Initial areas cover every recorded Reach; later revisions may cover a subset in
the existing CRS/type. This is the current schema limitation, not a requirement
that historic projects had polygons. See [the feature](../features/set-reach-areas.md).

## Acquired Survey Event inventory

`fg_record_survey_event.rsx` declares INPUT, exact saved REACH_ID, ACQUIRED_DATE
as YYYY/ YYYY-MM/ YYYY-MM-DD, SOURCE_REFERENCE, multiline EVIDENCE and new
CONTEXT/OUTPUT destinations. The actual registry ID is `r:fgrecordsurveyevent`.
fluvgeo owns date validation, parent matching, repeat refusal and publication.
The wrapper does not parse source names for dates or treat a source reference as
an asset link. Planned/undated work remains in notes. See
[the feature contract](../features/record-survey-event.md).

## Event terrain association

`fg_associate_event_terrain.rsx` declares INPUT, exact EVENT_ID, TERRAIN as a
GeoTIFF file, multiline EVIDENCE, ANALYST, and new MANIFEST/CONTEXT/OUTPUT paths.
The verified registry ID is `r:fgassociateeventterrain`.
The adapter delegates all association, root-relative path, integrity and
publication rules to fluvgeo inside the spatial guard. It does not use automatic
QGIS raster transport, copy/export rasters or infer event identities from filenames.
MANIFEST must live inside the context tree, beside an already linked manifest;
TERRAIN must be inside that manifest root. See
[the feature](../features/associate-event-terrain.md).

## Terrain metadata assertions

`fg_record_terrain_metadata.rsx` accepts INPUT, EVENT_ID, VERTICAL_UNIT,
VERTICAL_REFERENCE, EVIDENCE, ANALYST, MANIFEST, CONTEXT and OUTPUT. Optional blank
vertical fields remain unchanged/unknown. At least one must supply new metadata.
The shared `record_study_terrain_metadata()` backend fills previously unknown
fields in a new manifest/context, with attributed evidence. It preserves raster
bytes and prior snapshots; it does not transform elevations or certify assertions.
A shared file's metadata applies to all its event associations.
See [the feature](../features/record-terrain-metadata.md).
