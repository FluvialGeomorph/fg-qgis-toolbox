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
