##fg_review_stream_network=name
##Review Stream Network GeoPackage (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##OUTPUT=output html

#' ALG_DESC: Read-only review of a fluvgeo network GeoPackage. Creates an offline Terrain Development report with fresh network findings and next actions. Experimental: actual QGIS execution is not yet qualified.
#' : Select the complete governed bundle, not a single vector layer or an arbitrary GeoPackage. No repairs, reprojection, hierarchy reconstruction or acceptance are performed. Study Area boundary, Reach definitions, Survey Events and terrain are not inferred from this network-only input; their absence remains visible. This is not a complete Study Area report or an FGDB readiness certificate.
#' : Requires a compatible fluvgeo installation with terrain_development_summary and terrain_development_report, their dependencies, and Pandoc visible to the R subprocess. No packages are installed by this script. Use a persistent local output location for a durable record, not a temporary Processing output.
#' ALG_VERSION: 0.0.0.9000
#' INPUT: Existing FLUVGEO_NETWORK_GPKG_1 bundle created by fluvgeo, with its native geometry, CRS and relations. Draft observations are allowed. The source file and saved review history are never modified. Raw extraction outputs must first use the backend preparation workflow.
#' OUTPUT: New self-contained .html report in an existing directory on a local hard-link-capable filesystem. Existing files are refused, not overwritten. Invalid input or report-generation failures stop the tool; missing study context appears as findings rather than fabricated data.

if (!requireNamespace("fluvgeo", quietly = TRUE) ||
    !all(c("terrain_development_summary", "terrain_development_report") %in%
         getNamespaceExports("fluvgeo"))) {
  stop("A compatible fluvgeo installation with Terrain Development reporting is required; no packages were installed.",
       call. = FALSE)
}
review <- fluvgeo::terrain_development_summary(network = INPUT)
OUTPUT <- fluvgeo::terrain_development_report(review, output_file = OUTPUT)
