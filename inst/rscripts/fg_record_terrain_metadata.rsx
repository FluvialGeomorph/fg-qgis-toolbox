##fg_record_terrain_metadata=name
##Record Terrain Metadata (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##EVENT_ID=string
##VERTICAL_UNIT=optional string
##VERTICAL_REFERENCE=optional string
##EVIDENCE=string long
##ANALYST=string
##MANIFEST=output file json
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Record evidence-backed elevation units and/or a vertical reference for an already selected terrain file. Blank fields remain unchanged or unknown. Supply at least one new field; do not guess from filenames or horizontal CRS.
#' : Metadata belongs to the file: every event sharing that file uses the same assertion. Existing known values cannot be replaced with this initial-entry tool. Attribution is not approval or independent verification.
#' : No raster values, CRS, masks or original snapshots are changed. NoData masking deliberately defines an area of interest; percentages of a raster rectangle are not quality measures. No conversion, resampling or comparison is performed.
#' : Save new manifest/context/report files. A later failure can leave earlier outputs; retain them for inspection. Requires compatible fluvgeo, the fgqgis spatial guard, Pandoc and qualified R Provider. Nothing is installed.
#' ALG_VERSION: 0.0.0.9013
#' INPUT: Existing saved Study Area context with associated terrain.
#' EVENT_ID: Exact saved Survey Event UUID whose selected terrain is being described.
#' VERTICAL_UNIT: Optional evidenced elevation unit, e.g. metre, foot or explicitly US survey foot. Blank preserves unknown/current value. Horizontal coordinate units do not establish elevation units.
#' VERTICAL_REFERENCE: Optional evidenced vertical datum/reference, including realization or epoch when relevant. Blank preserves unknown/current value.
#' EVIDENCE: Required source and basis supporting the supplied fields. Do not substitute a filename guess for metadata evidence.
#' ANALYST: Required attribution for this entry; not an approval signature.
#' MANIFEST: New .json beside the current linked manifest. Prior fingerprints and evidence are retained.
#' CONTEXT: New .gpkg beside INPUT. Use this revised context in subsequent steps.
#' OUTPUT: New Define Study Area HTML with assertions and remaining questions.

if (!requireNamespace("fgqgis",quietly=TRUE) || !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis"))
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.",call.=FALSE)
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo",quietly=TRUE) || !"record_study_terrain_metadata" %in% getNamespaceExports("fluvgeo"))
    stop("A compatible fluvgeo installation with terrain metadata recording is required; no packages were installed.",call.=FALSE)
  result <- fluvgeo::record_study_terrain_metadata(INPUT,CONTEXT,EVENT_ID,
    VERTICAL_UNIT,VERTICAL_REFERENCE,EVIDENCE,ANALYST,MANIFEST,OUTPUT)
  MANIFEST <- result$manifest; CONTEXT <- result$context; OUTPUT <- result$report
})
