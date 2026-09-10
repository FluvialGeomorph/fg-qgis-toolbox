##fg_revise_study_area=name
##Revise Study Area Details (experimental)=display_name
##FluvialGeomorph=group
##dont_load_any_packages
##INPUT=file gpkg
##NEW_NAME=optional string
##ADD_NOTE=optional string long
##CONTEXT=output file gpkg
##OUTPUT=output html

#' ALG_DESC: Save an intentional Study Area name change or appended scope note in a new context GeoPackage, then regenerate the Terrain Development report. Review the current report first. This is a small editor, not a full Study Area configuration form.
#' : Blank fields keep current values. Notes are appended, never replaced; the dialog does not automatically prefill saved text. At least one change is required. Identities, AOIs, Streams, Reaches, Survey Events, terrain selections and forensic decisions remain unchanged. No acceptance, reprojection, source repair or FGDB loading occurs.
#' : Requires compatible fgqgis spatial-environment isolation, fluvgeo revise_study_context, and Pandoc. No packages are installed or profiles changed. Keep the context beside its source and retain all linked files. The two outputs are not a transaction: a failure or cancellation after saving may leave the new context. Inspect it and use Review Saved Study Area to retry reporting; do not overwrite it or assume a canceled output was accepted.
#' : Development profile only: free-text transport requires the qualified 4.1.0-fg-text1 provider correction. The older 4.1.0/fg-cancel1 serializer can alter literal backslashes in notes. Do not deploy this editor with that serializer.
#' ALG_VERSION: 0.0.0.9003
#' INPUT: Existing FLUVGEO_STUDY_CONTEXT_1 GeoPackage with unchanged linked network/manifest. The source and existing notes are preserved. Missing terrain remains visible in the report.
#' NEW_NAME: Optional new display name for the existing Study Area; blank keeps its name. This cannot create a missing Study Area or change its identity or AOI.
#' ADD_NOTE: Optional scope note to append as a new paragraph. Blank keeps existing notes. Include the reason or attribution when useful; this text is not an approval signature.
#' CONTEXT: New .gpkg beside INPUT, for example study-revised.gpkg. Choose a persistent path, not a temporary Processing destination. Existing files are refused; no linked assets are copied or repinned to replacements.
#' OUTPUT: New self-contained .html report in an existing local hard-link-capable directory. Existing reports are refused before any context is saved. Rendering failures can leave the new context for inspection.

if (!requireNamespace("fgqgis", quietly = TRUE) ||
    !"with_qgis_spatial_environment" %in% getNamespaceExports("fgqgis")) {
  stop("A compatible fgqgis installation with the spatial environment guard is required; no packages were installed.", call. = FALSE)
}
fgqgis::with_qgis_spatial_environment({
  if (!requireNamespace("fluvgeo", quietly = TRUE) ||
      !"revise_study_context" %in% getNamespaceExports("fluvgeo")) {
    stop("A compatible fluvgeo installation with Study Area revision is required; no packages were installed.", call. = FALSE)
  }
  optional_text <- function(x) if (is.null(x) || identical(x, "") ||
    (is.character(x) && length(x) == 1L && !is.na(x) && !nzchar(trimws(x)))) NULL else x
  revised <- fluvgeo::revise_study_context(INPUT, CONTEXT,
    study_area_name = optional_text(NEW_NAME), add_note = optional_text(ADD_NOTE), report_file = OUTPUT)
  CONTEXT <- revised$context
  OUTPUT <- revised$report
})
