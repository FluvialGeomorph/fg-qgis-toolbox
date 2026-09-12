# Run with the same R environment as the provider, using installed packages.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) %in% 3:6)
revision <- length(args) >= 5L && identical(args[4], "revise-context")
study_context <- revision || (length(args) >= 4L && identical(args[4], "study-context"))
purpose <- if (revision && length(args) == 6L) args[6] else
  if (!revision && study_context && length(args) >= 5L) args[5] else "terrain"
references <- !revision && study_context && length(args) == 6L && identical(args[6], "True")
.libPaths(c(args[1], .libPaths()))
warnings_seen <- character()
result <- withCallingHandlers(fgqgis::with_qgis_spatial_environment({
  if (revision) {
    original <- fluvgeo::read_study_context(args[5])
    revised <- fluvgeo::read_study_context(args[2])
    edits <- jsonlite::read_json(file.path(args[3], "edit-values.json"))
    expected_note <- if (is.na(original$analyst_notes)) edits$ADD_NOTE else
      paste(original$analyst_notes, edits$ADD_NOTE, sep = "\n\n")
    stopifnot(identical(revised$study_area$study_area_name, edits$NEW_NAME),
      identical(revised$analyst_notes, expected_note))
    revised$study_area$study_area_name <- original$study_area$study_area_name
    revised$analyst_notes <- original$analyst_notes
    stopifnot(identical(revised, original))
  }
  review_args <- list(dsn = args[2])
  if (references) review_args$terrain_references <- TRUE
  review <- if (study_context) do.call(fluvgeo::read_study_context_summary, review_args) else
    fluvgeo::terrain_development_summary(network = args[2])
  output <- if (study_context && purpose != "terrain")
    do.call(fluvgeo::study_context_report, c(review_args,
      list(output_file = file.path(args[3], "direct-report.html"), purpose = purpose))) else
    fluvgeo::terrain_development_report(review, file.path(args[3], "direct-report.html"))
  list(r = R.version.string, fluvgeo = as.character(utils::packageVersion("fluvgeo")),
    fluvgeo_path = find.package("fluvgeo"), sf = as.character(utils::packageVersion("sf")),
    terra = as.character(utils::packageVersion("terra")), spatial = as.list(sf::sf_extSoftVersion()),
    locale = Sys.getlocale(), segment_count = nrow(review$segments),
    validation_result = review$validation$stream_network_validation_run$result,
    gaps = review$gaps, terrain_references = references,
    reference_files = if (references) review$terrain_review$files else NULL,
    reference_links = if (references) review$terrain_review$context_links else NULL)
}), warning = function(w) {
  warnings_seen <<- c(warnings_seen, conditionMessage(w))
  invokeRestart("muffleWarning")
})
result$warnings <- unique(warnings_seen)
if (revision) result$only_requested_text_changed <- TRUE
provider <- xml2::read_html(file.path(args[3], if (study_context) "study review.html" else "network review.html"))
direct <- xml2::read_html(file.path(args[3], "direct-report.html"))
stopifnot(identical(xml2::xml_text(xml2::xml_find_first(provider, "//title")),
                   xml2::xml_text(xml2::xml_find_first(direct, "//title"))))
result$report_purpose <- purpose
tables <- function(doc) vapply(xml2::xml_find_all(doc, "//table"),
  function(x) gsub("[[:space:]]+", " ", xml2::xml_text(x)), character(1))
pt <- tables(provider); dt <- tables(direct)
stopifnot(length(pt) == length(dt))
result$table_count <- c(provider = length(pt), direct = length(dt))
result$identical_tables <- which(pt == dt)
result$different_tables <- which(pt != dt)
result$different_table_text <- lapply(result$different_tables,
  function(i) list(table = i, provider = pt[i], direct = dt[i]))
stable <- function(x) {
  generated <- grepl("^\\s*validation_level\\s+result\\s+validated_at\\s", x)
  x[generated] <- sub("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}",
                      "<generated timestamp>", x[generated])
  x
}
result$tables_match_except_validation_timestamp <- identical(stable(pt), stable(dt))
jsonlite::write_json(result, file.path(args[3], "direct-evidence.json"),
                     pretty = TRUE, auto_unbox = TRUE)
print(result)
stopifnot(result$tables_match_except_validation_timestamp)
