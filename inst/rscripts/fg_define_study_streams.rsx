##fg_define_study_streams=name
##Define Initial Study Streams (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##STREAM_NAMES=optional string long
##STREAM_SOURCE=optional file gpkg
##SOURCE_LAYER=optional string
##NAME_FIELD=optional string
##RATIONALE=string long
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Define the first Stream inventory under a saved Study Area. Either enter names (one per line) without areas, or supply a prepared GeoPackage layer/table and its name field. Save a new context and Define Study Area report. Existing Stream or related hierarchy/network records are refused, not replaced.
#' : Each chosen row becomes one new local Stream identity. No source identifiers are adopted or reconciled. Names and any supplied polygons are analyst choices, not derived from terrain or a mandatory HUC rule. No Reaches, Survey Events, clipping, dissolve, reprojection or acceptance is inferred. Polygon coordinates and CRS are retained; containment/coverage suitability still needs review.
#' : Requires compatible fgqgis/fluvgeo, Pandoc and the qualified 4.1.0-fg-text1 provider. No package installation or profile changes occur. Failure/cancellation after saving can leave the new context; inspect it and use Review Saved Study Area to retry reporting rather than defining the Streams again.
#' ALG_VERSION: 0.0.0.9007
#' INPUT: Saved Study Area context with an existing Study Area identity and no Streams, Reaches, Survey Events or linked network. Boundary and terrain are optional.
#' STREAM_NAMES: Names-only mode: one name per line; blank lines are ignored. Leave all source fields empty. No areas or acquired data are required.
#' STREAM_SOURCE: Source mode: prepared GeoPackage polygon layer or nonspatial table. Leave STREAM_NAMES empty. All rows are imported, NOT just a live QGIS selection; export your intended subset beforehand.
#' SOURCE_LAYER: Exact layer/table name in STREAM_SOURCE. No automatic layer selection.
#' NAME_FIELD: Exact text field containing the chosen Stream names. Only it and optional polygon geometry are imported; all other source attributes are ignored explicitly.
#' RATIONALE: Required source and naming/segmentation rationale, appended to the study's notes. Names must be nonempty and unique ignoring case in this initial-definition tool.
#' CONTEXT: New .gpkg beside INPUT; originals and existing destinations are preserved. Continue this new context to retain the generated Stream identities.
#' OUTPUT: New Define Study Area .html report. Existing reports are refused before saving. Context/report publication is not a single transaction.

if (!requireNamespace("fgqgis", quietly = TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis"))
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call. = FALSE)
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly = TRUE) ||
      !"define_study_streams" %in% getNamespaceExports("fluvgeo"))
    stop("A compatible fluvgeo installation with initial Stream definition is required; no packages were installed.", call. = FALSE)
  blank <- function(x) is.null(x) || (is.character(x) && length(x) == 1L && !is.na(x) && !nzchar(trimws(x)))
  if (!blank(STREAM_NAMES)) {
    if (!blank(STREAM_SOURCE) || !blank(SOURCE_LAYER) || !blank(NAME_FIELD))
      stop("Choose names-only or source mode, not both.", call. = FALSE)
    values <- trimws(strsplit(STREAM_NAMES, "\r?\n")[[1]])
    selected <- data.frame(stream_name = values[nzchar(values)])
    field <- "stream_name"
  } else {
    if (blank(STREAM_SOURCE) || blank(SOURCE_LAYER) || blank(NAME_FIELD))
      stop("Enter Stream names, or supply STREAM_SOURCE, SOURCE_LAYER and NAME_FIELD together.", call. = FALSE)
    selected <- sf::st_read(STREAM_SOURCE, layer = SOURCE_LAYER, quiet = TRUE)
    field <- NAME_FIELD
  }
  result <- fluvgeo::define_study_streams(INPUT, CONTEXT, selected,
    name_column = field, add_note = RATIONALE, report_file = OUTPUT)
  CONTEXT <- result$context
  OUTPUT <- result$report
})
