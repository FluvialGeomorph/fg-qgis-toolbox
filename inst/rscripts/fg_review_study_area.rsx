##fg_review_study_area=name
##Review Saved Study Area (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##OUTPUT=output html

#' ALG_DESC: Reopen saved Study Area context and create the existing offline Terrain Development report. Shows supplied Streams, Reaches, Survey Events, forensic interpretations and freshly inspected network/terrain evidence. Experimental, not qualified for production deployment.
#' : Choose a context GeoPackage written by fluvgeo, not the network GeoPackage or an arbitrary layer. Keep it with its linked network, terrain manifest and external GeoTIFFs; move the complete folder together. No repairs, reprojection, identity assignment, data acceptance or FGDB loading occurs. Missing AOIs and unknown vertical references remain explicit.
#' : Requires fgqgis with its spatial environment guard, fluvgeo with read_study_context_summary and terrain_development_report, and Pandoc. No packages are installed and no QGIS settings are changed. Only recognizable OSGeo spatial-resource overrides are isolated; unknown overrides fail. Select a persistent output path for a durable record.
#' ALG_VERSION: 0.0.0.9002
#' INPUT: Existing FLUVGEO_STUDY_CONTEXT_1 GeoPackage. Network and manifest references must retain their saved hashes. Missing or changed terrain assets remain report findings; a missing or changed linked network/manifest stops reopening rather than substituting files. Stored records remain supplied context, not proof of scientific readiness.
#' OUTPUT: New self-contained .html report in an existing directory on a local hard-link-capable filesystem. Existing files are refused. The source context, linked files and review history are never modified. This report does not certify a complete Study Area or FGDB compliance.

if (!requireNamespace("fgqgis", quietly = TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis")) {
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call. = FALSE)
}
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly = TRUE) ||
      !all(c("read_study_context_summary", "terrain_development_report") %in%
           getNamespaceExports("fluvgeo"))) {
    stop("A compatible fluvgeo installation with saved Study Area reporting is required; no packages were installed.", call. = FALSE)
  }
  review <- fluvgeo::read_study_context_summary(INPUT)
  OUTPUT <- fluvgeo::terrain_development_report(review, output_file = OUTPUT)
})
