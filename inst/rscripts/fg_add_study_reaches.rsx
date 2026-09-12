##fg_add_study_reaches=name
##Add Study Reaches (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##STREAM_NAME=optional string
##REACH_NAMES=optional string long
##REACH_SOURCE=optional file gpkg
##SOURCE_LAYER=optional string
##NAME_FIELD=optional string
##PARENT_FIELD=optional string
##RATIONALE=string long
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Add explicitly chosen Reaches under existing Streams, save a new context and refresh the Define Study Area report. Either enter names for one Stream, or supply a prepared GeoPackage table/polygon layer with Reach names and parent Stream names. Other Streams can remain unfinished; existing records retain their identities.
#' : Parent names must match exactly one Stream in the saved context. No fuzzy matching, spatial assignment or automatic network segmentation occurs. Reach names may repeat across Streams, but duplicates within one Stream are refused, including existing Reaches. New local Reach IDs are created; source IDs are not adopted or reconciled.
#' : Optional areas are polygons, not flowlines. Appending requires the same geometry presence, polygon type and CRS as existing Reaches. No missing areas, reprojection, clipping, containment approval or Survey Events are invented. Names-only drafts need no acquired data.
#' : Requires compatible fgqgis/fluvgeo, Pandoc and the qualified 4.1.0-fg-text1 provider. No installation or profile changes. A failure/cancellation after saving can leave the new context; inspect it and retry with Review Saved Study Area. Continue that saved output rather than adding the same Reaches to the older draft again.
#' ALG_VERSION: 0.0.0.9008
#' INPUT: Saved Study Area context with existing Study Area and Stream identities. All existing records and source files are preserved.
#' STREAM_NAME: Names-only mode: exact name of one saved Stream. Leave all source fields empty. Use the report's Stream inventory; ambiguous names require the R API's explicit Stream-ID reference.
#' REACH_NAMES: Names-only mode: one new Reach name per line under STREAM_NAME. Blank lines are ignored. No areas are inferred.
#' REACH_SOURCE: Source mode: prepared GeoPackage table or polygon layer, potentially spanning several Streams. Leave STREAM_NAME and REACH_NAMES empty. Every row is imported, not a live QGIS selection.
#' SOURCE_LAYER: Exact layer/table name in REACH_SOURCE.
#' NAME_FIELD: Exact text field containing Reach names. Other attributes, including source Reach IDs, are explicitly ignored.
#' PARENT_FIELD: Exact text field containing parent Stream names as shown in the saved report. Each must match exactly one existing Stream.
#' RATIONALE: Required source and segmentation/assignment rationale, appended to existing notes. Not an approval signature.
#' CONTEXT: New .gpkg beside INPUT, never an existing file. Continue this output to retain all Reach identities.
#' OUTPUT: New Define Study Area .html report. Existing reports are refused before saving. Context and report are not a single transaction.

if (!requireNamespace("fgqgis", quietly=TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis"))
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call.=FALSE)
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly=TRUE) || !"add_study_reaches" %in% getNamespaceExports("fluvgeo"))
    stop("A compatible fluvgeo installation with Reach addition is required; no packages were installed.", call.=FALSE)
  blank <- function(x) is.null(x) || (is.character(x) && length(x)==1L && !is.na(x) && !nzchar(trimws(x)))
  if (!blank(REACH_NAMES) || !blank(STREAM_NAME)) {
    if (blank(REACH_NAMES) || blank(STREAM_NAME)) stop("Supply STREAM_NAME and REACH_NAMES together.", call.=FALSE)
    if (!blank(REACH_SOURCE) || !blank(SOURCE_LAYER) || !blank(NAME_FIELD) || !blank(PARENT_FIELD))
      stop("Choose names-only or source mode, not both.", call.=FALSE)
    values <- trimws(strsplit(REACH_NAMES,"\r?\n")[[1]])
    values <- values[nzchar(values)]
    selected <- data.frame(reach_name=values, stream_name=rep(STREAM_NAME,length(values)))
    name_field <- "reach_name"; parent_field <- "stream_name"
  } else {
    if (blank(REACH_SOURCE) || blank(SOURCE_LAYER) || blank(NAME_FIELD) || blank(PARENT_FIELD))
      stop("Supply the source, layer, name and parent fields together, or enter names for one Stream.", call.=FALSE)
    selected <- sf::st_read(REACH_SOURCE,layer=SOURCE_LAYER,quiet=TRUE)
    name_field <- NAME_FIELD; parent_field <- PARENT_FIELD
  }
  result <- fluvgeo::add_study_reaches(INPUT,CONTEXT,selected,name_column=name_field,
    parent_column=parent_field,parent_key="stream_name",add_note=RATIONALE,report_file=OUTPUT)
  CONTEXT <- result$context
  OUTPUT <- result$report
})
