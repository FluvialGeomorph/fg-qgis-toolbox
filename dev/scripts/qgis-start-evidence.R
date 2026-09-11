# Installed-library comparison for the actual new-study provider run.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
.libPaths(c(args[1], .libPaths()))
root <- args[2]
result <- fgqgis::with_qgis_spatial_environment({
  values <- jsonlite::read_json(file.path(root, "start-values.json"))
  folder <- file.path(root, "New Cr\u00e9ek drafts")
  context <- file.path(folder, "developer draft.gpkg")
  blank <- file.path(folder, "blank notes.gpkg")
  nested <- file.path(folder, "absent", "draft.gpkg")
  before <- tools::md5sum(c(context, blank, nested))
  original <- fluvgeo::read_study_context(context)
  empty <- fluvgeo::read_study_context(blank)
  created <- fluvgeo::read_study_context(nested)
  stopifnot(identical(created$study_area$study_area_name, values$STUDY_NAME),
    identical(created$analyst_notes, values$SCOPE_NOTES),
    identical(names(created), names(original)),
    length(unique(c(original$study_area$study_area_id, empty$study_area$study_area_id,
      created$study_area$study_area_id))) == 3L)
  stopifnot(identical(original$study_area$study_area_name, values$STUDY_NAME),
    identical(original$analyst_notes, values$SCOPE_NOTES), is.na(empty$analyst_notes),
    identical(names(original), c("study_area", "terrain_notes", "analyst_notes")),
    !identical(original$study_area$study_area_id, empty$study_area$study_area_id))
  summary <- fluvgeo::read_study_context_summary(context)
  stopifnot(nrow(summary$surveys) == 0L, !inherits(original$study_area, "sf"))
  direct <- fluvgeo::define_study_area_report(summary, file.path(root, "direct-report.html"))
  body <- function(path) {
    doc <- xml2::read_html(path)
    x <- xml2::xml_find_first(doc, "//div[contains(@class, 'main-container')]")
    # Script/style payload is not visible content. Only snapshot time may differ.
    xml2::xml_remove(xml2::xml_find_all(x, ".//script|.//style"))
    text <- gsub("[[:space:]]+", " ", xml2::xml_text(x))
    sub("Snapshot: [0-9-]+ [0-9:]+ UTC", "Snapshot: <generated>", text)
  }
  stopifnot(identical(body(file.path(root, "define study area.html")), body(direct)),
    identical(tools::md5sum(c(context, blank, nested)), before))
  list(r = R.version.string, fgqgis = as.character(utils::packageVersion("fgqgis")),
    fluvgeo = as.character(utils::packageVersion("fluvgeo")),
    fluvgeo_path = find.package("fluvgeo"), spatial = as.list(sf::sf_extSoftVersion()),
    exact_text = TRUE, blank_notes_missing = TRUE, no_acquired_data_inferred = TRUE,
    independent_starts_distinct_ids = TRUE, report_body_matches_except_snapshot = TRUE,
    contexts_unchanged_by_review = TRUE)
})
jsonlite::write_json(result, file.path(root, "direct-evidence.json"), pretty = TRUE, auto_unbox = TRUE)
print(result)
