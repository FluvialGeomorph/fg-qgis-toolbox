##fg_associate_event_terrain=name
##Associate Event Terrain (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##EVENT_ID=string
##TERRAIN=file tif
##EVIDENCE=string long
##ANALYST=string
##MANIFEST=output file json
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Associate one local single-band GeoTIFF with an existing Survey Event and select it for grid metadata review. Save a new manifest, context and Define Study Area report. Existing event selections are refused, not replaced.
#' : Place the GeoTIFF in the manifest folder or its descendants first. The manifest must stay inside the context folder tree; if one is already linked, save the new manifest beside it. This tool does not copy or convert archive data. Keep the entire linked folder together.
#' : Original identities, records, fingerprints and sources are preserved. A matching fingerprint or loaded grid is not scientific acceptance. Vertical metadata stays unknown unless already recorded; filenames are not evidence. No reprojection, valid-cell assessment or FGDB loading occurs.
#' : Requires compatible fluvgeo, fgqgis spatial guard, Pandoc and qualified R Provider 4.1.0-fg-text1. Nothing is installed. Outputs are not one transaction: a later failure/cancellation can leave the manifest and context. Keep published outputs for inspection; use Review Saved Study Area if the context was saved.
#' ALG_VERSION: 0.0.0.9011
#' INPUT: Existing context GeoPackage. Continue each new context to retain prior associations.
#' EVENT_ID: Exact saved survey_event_id from the report Supporting record or survey_events table. No date/name matching or new event creation.
#' TERRAIN: Existing GeoTIFF inside the manifest folder tree. No FileGDB export, source modification or file copying is performed.
#' EVIDENCE: Required basis for this file-to-event association, including source and remaining uncertainty. Not a substitute for vertical metadata.
#' ANALYST: Required attribution supplied by the caller; not an approval signature.
#' MANIFEST: New .json inside the context folder tree, beside the current manifest if one exists. Never overwrite. Assets resolve relative to this folder.
#' CONTEXT: New .gpkg beside INPUT, linked to MANIFEST. Never overwrite.
#' OUTPUT: New Define Study Area .html report with associated terrain and unresolved findings.

if (!requireNamespace("fgqgis", quietly=TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis"))
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call.=FALSE)
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly=TRUE) || !"associate_study_terrain" %in% getNamespaceExports("fluvgeo"))
    stop("A compatible fluvgeo installation with terrain association is required; no packages were installed.", call.=FALSE)
  result <- fluvgeo::associate_study_terrain(INPUT,CONTEXT,EVENT_ID,TERRAIN,
    EVIDENCE,ANALYST,MANIFEST,report_file=OUTPUT)
  CONTEXT <- result$context
  OUTPUT <- result$report
  MANIFEST <- result$manifest
})
