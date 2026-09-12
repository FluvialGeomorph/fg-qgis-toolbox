##fg_record_survey_event=name
##Record Survey Event (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##REACH_ID=string
##ACQUIRED_DATE=string
##SOURCE_REFERENCE=string
##EVIDENCE=string long
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Record one acquired Survey Event under an existing Reach and refresh the Define Study Area report. Continue the new saved context for further acquisitions. Existing hierarchy, areas, events and evidence links are preserved.
#' : Supply only known date precision: YYYY, YYYY-MM or YYYY-MM-DD. Missing month/day stay unknown. Plans and undated historic acquisitions belong in scope/reconstruction notes until evidence is available. Future periods are refused.
#' : Source and evidence are analyst statements, not verified file links. This tool does not read, copy or validate terrain, select an event raster, or reconcile enterprise identities. Exact repeats of Reach/date/source are refused; alternative labels or date precision need analyst duplicate review.
#' : Requires compatible fluvgeo, fgqgis spatial guard, Pandoc and qualified R Provider 4.1.0-fg-text1. Nothing is installed. Failure/cancellation after saving may leave the context; keep it and retry with Review Saved Study Area.
#' ALG_VERSION: 0.0.0.9010
#' INPUT: Saved Study Area context. Reach areas and acquired terrain files are not prerequisites for recording acquisition evidence.
#' REACH_ID: Exact existing reach_id from the saved reaches table or report Supporting record. No name matching or new Reach creation.
#' ACQUIRED_DATE: Known acquisition date, e.g. 2016, 2016-05 or 2016-05-23. Do not substitute a processing/file-modification year or a planned date.
#' SOURCE_REFERENCE: Nonempty reference identifying the source dataset or delivery evidence. Text only; not opened or verified as a path.
#' EVIDENCE: Required basis for the acquisition/date interpretation and availability limitations. Stored with the event, not duplicated in Study Area notes.
#' CONTEXT: New .gpkg beside INPUT. Continue this output to retain event identities.
#' OUTPUT: New Define Study Area .html report. Existing destinations are refused; context and report are not one transaction.

if (!requireNamespace("fgqgis", quietly=TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis"))
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call.=FALSE)
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly=TRUE) || !"record_study_survey_event" %in% getNamespaceExports("fluvgeo"))
    stop("A compatible fluvgeo installation with acquired-event recording is required; no packages were installed.", call.=FALSE)
  result <- fluvgeo::record_study_survey_event(INPUT,CONTEXT,REACH_ID,ACQUIRED_DATE,
    SOURCE_REFERENCE,EVIDENCE,report_file=OUTPUT)
  CONTEXT <- result$context
  OUTPUT <- result$report
})
