##fg_start_study_area=name
##Start Study Area (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##STUDY_NAME=string
##SCOPE_NOTES=optional string long
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Begin a genuinely new Study Area with a working name and optional customer-purpose/scope notes. Save a context GeoPackage and a short Define Study Area report showing what is known and the next design decisions. No archive, terrain, boundary or completed survey is required.
#' : A new local identity is generated; do not use this to reopen an existing study or reconstruct a legacy identity. Continue existing drafts with Revise Study Area Details. No Streams, Reaches, acquisition dates, CRS or approval are invented. This starter is not a full hierarchy editor or an FGDB loader.
#' : Requires compatible fgqgis, fluvgeo start_study_context, Pandoc and the qualified development text provider 4.1.0-fg-text1. No packages are installed or profiles changed. Existing files are refused. Saving and reporting are not one transaction: failure or cancellation after saving can leave a context. Keep it and retry read-only reporting; do not create another identity merely to recover a report.
#' ALG_VERSION: 0.0.0.9004
#' STUDY_NAME: Required working display name. Outer whitespace is trimmed. A later rename preserves the saved identity.
#' SCOPE_NOTES: Optional purpose, customer question, candidate scope and open decisions. Blank leaves notes unrecorded. Intended observations remain notes, not dated Survey Event records.
#' CONTEXT: New persistent .gpkg in an existing local hard-link-capable directory. No source files are required or copied. Keep this as the editable draft record.
#' OUTPUT: New self-contained .html Define Study Area report in an existing local hard-link-capable directory. Existing destinations are refused before saving the context.

if (!requireNamespace("fgqgis", quietly = TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis")) {
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call. = FALSE)
}
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly = TRUE) ||
      !"start_study_context" %in% getNamespaceExports("fluvgeo")) {
    stop("A compatible fluvgeo installation with Study Area creation is required; no packages were installed.", call. = FALSE)
  }
  notes <- if (is.null(SCOPE_NOTES) || identical(SCOPE_NOTES, "") ||
    (is.character(SCOPE_NOTES) && length(SCOPE_NOTES) == 1L &&
      !is.na(SCOPE_NOTES) && !nzchar(trimws(SCOPE_NOTES)))) NA_character_ else SCOPE_NOTES
  draft <- fluvgeo::start_study_context(CONTEXT, STUDY_NAME,
    analyst_notes = notes, report_file = OUTPUT)
  CONTEXT <- draft$context
  OUTPUT <- draft$report
})
