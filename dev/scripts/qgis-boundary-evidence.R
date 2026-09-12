# Read-only comparison of QGIS output with direct backend behavior.
args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 2L)
.libPaths(c(args[1], .libPaths()))
Sys.unsetenv(c("GDAL_DRIVER_PATH", "GDAL_DATA", "PROJ_LIB", "PROJ_DATA"))
root <- args[2]
p <- jsonlite::read_json(file.path(root, "parameters.json"), simplifyVector = TRUE)
before <- tools::md5sum(c(p$INPUT, p$BOUNDARY, p$CONTEXT, p$OUTPUT))
boundary <- sf::st_read(p$BOUNDARY, layer = p$BOUNDARY_LAYER, quiet = TRUE)
source <- fluvgeo::read_study_context(p$INPUT)
actual <- fluvgeo::read_study_context(p$CONTEXT)
stopifnot(identical(sf::st_drop_geometry(actual$study_area), source$study_area),
  identical(sf::st_as_binary(sf::st_geometry(actual$study_area)), sf::st_as_binary(sf::st_geometry(boundary))),
  isTRUE(sf::st_crs(actual$study_area) == sf::st_crs(boundary)),
  identical(actual$analyst_notes, paste(source$analyst_notes,
    paste0("Study Area boundary supplied: ", p$RATIONALE), sep = "\n\n")))
unchanged <- actual; unchanged$study_area <- source$study_area; unchanged$analyst_notes <- source$analyst_notes
stopifnot(identical(unchanged, source))
direct <- fluvgeo::revise_study_context(p$INPUT, file.path(dirname(p$INPUT), "direct.gpkg"),
  study_area_boundary = boundary, add_note = p$RATIONALE,
  report_file = file.path(root, "direct.html"), report_purpose = "definition")
stopifnot(isTRUE(all.equal(actual, fluvgeo::read_study_context(direct$context))))
tables <- function(path) {
  doc <- xml2::read_html(path)
  stopifnot(xml2::xml_text(xml2::xml_find_first(doc, ".//title")) == "Define Study Area",
    any(grepl("data:image/png;base64", xml2::xml_attr(xml2::xml_find_all(doc, ".//img"), "src"), fixed = TRUE)))
  vapply(xml2::xml_find_all(doc, ".//table"), as.character, character(1))
}
stopifnot(identical(tables(p$OUTPUT), tables(direct$report)), identical(tools::md5sum(names(before)), before))
images <- xml2::xml_attr(xml2::xml_find_all(xml2::read_html(p$OUTPUT), ".//img"), "src")
embedded <- images[grepl("^data:image/png;base64,", images)]
stopifnot(length(embedded) == 1L)
writeBin(openssl::base64_decode(sub("^data:image/png;base64,", "", embedded)),
  file.path(root, "boundary-map.png"))
jsonlite::write_json(list(context_matches_direct = TRUE, native_geometry_and_crs_preserved = TRUE,
  notes_preserved = TRUE, report_tables_match = TRUE, source_outputs_unchanged = TRUE),
  file.path(root, "direct-evidence.json"), auto_unbox = TRUE, pretty = TRUE)
