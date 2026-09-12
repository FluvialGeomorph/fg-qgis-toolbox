##fg_set_study_boundary=name
##Set Study Area Boundary (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##BOUNDARY=file gpkg
##BOUNDARY_LAYER=string
##RATIONALE=string long
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Attach or replace an analyst-chosen boundary on an existing Study Area, save a new context and render a Define Study Area report. The study identity, name, Streams, Reaches, Survey Events and linked evidence are preserved.
#' : Prepare a GeoPackage layer containing exactly one valid polygon or multipart polygon with a known CRS. If using several HUCs, deliberately dissolve/export the chosen features first. This tool reads the entire named layer, not the current QGIS selection. HUC boundaries are optional, not a required Study Area convention.
#' : Only geometry is copied; source attributes do not rename or re-identify the study. No automatic dissolve, repair, reprojection, clipping, terrain processing or FGDB loading occurs. Existing child areas are not altered or asserted to fit the new boundary. Rationale is appended to the scope notes; this is not an approval signature or a complete provenance ledger.
#' : Requires the qualified 4.1.0-fg-text1 R Provider, fgqgis spatial guard, fluvgeo boundary revision and Pandoc. No installation or profile changes occur. A failure or cancellation after saving can leave the new context; inspect it and use Review Saved Study Area to retry reporting.
#' ALG_VERSION: 0.0.0.9006
#' INPUT: Existing saved Study Area context GeoPackage. No new Study Area identity is created.
#' BOUNDARY: Existing GeoPackage containing the analyst-prepared boundary; read-only. Export/dissolve a selection to one feature before using this tool.
#' BOUNDARY_LAYER: Exact layer name in BOUNDARY. Must contain one nonempty, valid XY POLYGON or MULTIPOLYGON with a defined CRS; no layer or feature is chosen automatically.
#' RATIONALE: Required source and reason for choosing or replacing this extent. Include attribution and unresolved scope questions as useful. Appended to existing notes.
#' CONTEXT: New .gpkg beside INPUT. Existing destinations are refused and no linked files are copied. Keep the original for comparison.
#' OUTPUT: New Define Study Area .html report in an existing local hard-link-capable directory. No overwrite; the report and context are not one transaction.

if (!requireNamespace("fgqgis", quietly = TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis")) {
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call. = FALSE)
}
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly = TRUE) ||
      !"revise_study_context" %in% getNamespaceExports("fluvgeo") ||
      !"study_area_boundary" %in% names(formals(fluvgeo::revise_study_context))) {
    stop("A compatible fluvgeo installation with Study Area boundary revision is required; no packages were installed.", call. = FALSE)
  }
  if (!is.character(BOUNDARY_LAYER) || length(BOUNDARY_LAYER) != 1L ||
      is.na(BOUNDARY_LAYER) || !nzchar(trimws(BOUNDARY_LAYER)))
    stop("Supply the exact BOUNDARY_LAYER name; no layer is chosen automatically.", call. = FALSE)
  boundary <- sf::st_read(BOUNDARY, layer = BOUNDARY_LAYER, quiet = TRUE)
  revised <- fluvgeo::revise_study_context(INPUT, CONTEXT,
    add_note = RATIONALE, study_area_boundary = boundary,
    report_file = OUTPUT, report_purpose = "definition")
  CONTEXT <- revised$context
  OUTPUT <- revised$report
})
