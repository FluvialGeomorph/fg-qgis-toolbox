##fg_review_study_area=name
##Review Saved Study Area (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##REPORT_VIEW=enum Terrain Development;Define Study Area;Staging Report 0
##TERRAIN_REFERENCES=boolean False
##OUTPUT=output html

#' ALG_DESC: Reopen saved Study Area context and choose an offline report view. Terrain Development retains the existing combined report; Define Study Area focuses on prospective scope; Staging Report focuses on reconstruction. The view does not change identities, records or acceptance. Experimental, not qualified for production deployment.
#' : Choose a context GeoPackage written by fluvgeo, not the network GeoPackage or an arbitrary layer. Keep it with its linked network, terrain manifest and external GeoTIFFs; move the complete folder together. No repairs, reprojection, identity assignment, data acceptance or FGDB loading occurs. Missing AOIs and unknown vertical references remain explicit.
#' : Requires fgqgis with its spatial environment guard, fluvgeo with study_context_report (terrain_references support for the optional review), gt and Pandoc. No packages are installed and no QGIS settings are changed. Only recognizable OSGeo spatial-resource overrides are isolated; unknown overrides fail. Select a persistent output path for a durable record.
#' ALG_VERSION: 0.0.0.9014
#' TERRAIN_REFERENCES: Optional read-only terrain reference review (off by default). Inspect only DEMs explicitly selected by saved event links. Display file declarations separately from recorded metadata and unresolved analysis choices. Missing/changed or otherwise blocked selections remain findings; no substitute files are searched for. No metadata is accepted or written, no elevations are transformed, and no source lineage is inferred. Inspection may take extra time. Available in all report views; a draft without selected terrain remains valid.
#' REPORT_VIEW: Terrain Development (default for compatibility), Define Study Area, or Staging Report. Choose Define Study Area to continue a new draft. The choice is not saved as a project type. Staging uses saved context only, not a fresh inspection of an unsaved archive path.
#' INPUT: Existing FLUVGEO_STUDY_CONTEXT_1 GeoPackage. Network and manifest references must retain their saved hashes. Missing or changed terrain assets remain report findings; a missing or changed linked network/manifest stops reopening rather than substituting files. Stored records remain supplied context, not proof of scientific readiness.
#' OUTPUT: New self-contained .html report in an existing directory on a local hard-link-capable filesystem. Existing files are refused. The source context, linked files and review history are never modified. This report does not certify a complete Study Area or FGDB compliance.

if (!requireNamespace("fgqgis", quietly = TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis")) {
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call. = FALSE)
}
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly = TRUE) ||
      !all(c("read_study_context_summary", "study_context_report") %in%
           getNamespaceExports("fluvgeo"))) {
    stop("A compatible fluvgeo installation with saved Study Area reporting is required; no packages were installed.", call. = FALSE)
  }
  view <- if (exists("REPORT_VIEW", inherits = FALSE)) REPORT_VIEW else 0L
  if (!is.numeric(view) || length(view) != 1L || is.na(view) || !view %in% 0:2)
    stop("REPORT_VIEW must select an available report view.", call. = FALSE)
  references <- if (exists("TERRAIN_REFERENCES", inherits = FALSE)) TERRAIN_REFERENCES else FALSE
  if (!is.logical(references) || length(references) != 1L || is.na(references))
    stop("TERRAIN_REFERENCES must be TRUE or FALSE.", call. = FALSE)
  arguments <- list(dsn = INPUT, output_file = OUTPUT,
    purpose = c("terrain", "definition", "staging")[[view + 1L]])
  if (references) {
    if (!"terrain_references" %in% names(formals(fluvgeo::study_context_report)))
      stop("A compatible fluvgeo installation with terrain-reference review is required; no packages were installed.", call. = FALSE)
    arguments$terrain_references <- TRUE
  }
  OUTPUT <- do.call(fluvgeo::study_context_report, arguments)
})
