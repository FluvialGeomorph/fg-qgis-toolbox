##fg_set_reach_areas=name
##Set Reach Areas (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##AREAS=file gpkg
##AREA_LAYER=string
##ID_FIELD=string
##RATIONALE=string long
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Supply or revise explicitly matched areas of existing Reaches and refresh the Define Study Area report. Identities, names, parent Streams, Survey Events and linked evidence are preserved.
#' : Prepare a GeoPackage polygon layer with a text field containing the exact reach_id values from the saved context's reaches table (also shown in the report's Supporting record). Deliberately join or copy those IDs to your selected polygons; archived IDs are not reconciled. Every source row is read, not a live QGIS selection. Other source attributes are ignored.
#' : If no Reach areas are saved, supply one area for every recorded Reach together. Once all areas exist, selected Reaches may be revised with the same CRS and polygon type. Mixed missing/supplied areas are not supported by this context format. No guessing, automatic delineation, repair, dissolve, reprojection, clipping or containment approval occurs.
#' : Requires fluvgeo Reach-area assignment, the fgqgis spatial guard, Pandoc and qualified R Provider 4.1.0-fg-text1. Nothing is installed. Failure/cancellation after saving may leave the new context; retain it and retry with Review Saved Study Area.
#' ALG_VERSION: 0.0.0.9009
#' INPUT: Existing saved Study Area context with named Reaches. No identities are generated.
#' AREAS: Read-only GeoPackage containing explicitly prepared Reach area polygons.
#' AREA_LAYER: Exact layer name; valid nonempty finite CRS-defined XY polygons of one type.
#' ID_FIELD: Exact text field containing existing reach_id values, one distinct saved ID per polygon. Copy these IDs from INPUT, not an unrelated archive.
#' RATIONALE: Required source and delineation/revision rationale, appended to the notes. Not an approval signature.
#' CONTEXT: New .gpkg beside INPUT. Never overwrite the original; continue the returned context.
#' OUTPUT: New Define Study Area .html report. Context and report are not a single transaction.

if (!requireNamespace("fgqgis", quietly=TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis"))
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call.=FALSE)
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly=TRUE) || !"set_study_reach_areas" %in% getNamespaceExports("fluvgeo"))
    stop("A compatible fluvgeo installation with Reach-area assignment is required; no packages were installed.", call.=FALSE)
  if (!is.character(AREA_LAYER) || length(AREA_LAYER)!=1L || is.na(AREA_LAYER) || !nzchar(trimws(AREA_LAYER)))
    stop("Supply the exact AREA_LAYER name.",call.=FALSE)
  areas <- sf::st_read(AREAS,layer=AREA_LAYER,quiet=TRUE)
  result <- fluvgeo::set_study_reach_areas(INPUT,CONTEXT,areas,id_column=ID_FIELD,
    add_note=RATIONALE,report_file=OUTPUT)
  CONTEXT <- result$context
  OUTPUT <- result$report
})
