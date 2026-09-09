##fg_review_stream_network=name
##Review Stream Network GeoPackage (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##OUTPUT=output html

#' ALG_DESC: Read-only review of a fluvgeo network GeoPackage. Creates an offline Terrain Development report with fresh network findings and next actions. Experimental: headless execution tested; desktop deployment is not yet qualified.
#' : Select the complete governed bundle, not a single vector layer or an arbitrary GeoPackage. No repairs, reprojection, hierarchy reconstruction or acceptance are performed. Study Area boundary, Reach definitions, Survey Events and terrain are not inferred from this network-only input; their absence remains visible. This is not a complete Study Area report or an FGDB readiness certificate.
#' : Requires fgqgis with with_qgis_spatial_environment, compatible fluvgeo reporting, and Pandoc visible to the fresh R subprocess. Recognizable OSGeo4W spatial-resource overrides are temporarily removed before loading the backend, so R uses its own resources. Unknown custom overrides or preloaded spatial packages stop the tool when isolation is needed. No packages are installed and no QGIS settings are changed. Use a persistent local output location, not a temporary Processing output.
#' ALG_VERSION: 0.0.0.9001
#' INPUT: Existing FLUVGEO_NETWORK_GPKG_1 bundle created by fluvgeo, with its native geometry, CRS and relations. Draft observations are allowed. The source file and saved review history are never modified. Raw extraction outputs must first use the backend preparation workflow.
#' OUTPUT: New self-contained .html report in an existing directory on a local hard-link-capable filesystem. Existing files are refused, not overwritten. Invalid input or report-generation failures stop the tool; missing study context appears as findings rather than fabricated data.

if (!requireNamespace("fgqgis", quietly = TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis")) {
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.",
       call. = FALSE)
}
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly = TRUE) ||
      !all(c("terrain_development_summary", "terrain_development_report") %in%
           getNamespaceExports("fluvgeo"))) {
    stop("A compatible fluvgeo installation with Terrain Development reporting is required; no packages were installed.",
         call. = FALSE)
  }
  review <- fluvgeo::terrain_development_summary(network = INPUT)
  OUTPUT <- fluvgeo::terrain_development_report(review, output_file = OUTPUT)
})
