args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==2L)
.libPaths(c(args[1],.libPaths())); Sys.unsetenv(c("GDAL_DRIVER_PATH","GDAL_DATA","PROJ_LIB","PROJ_DATA"))
root <- args[2]; p <- jsonlite::read_json(file.path(root,"parameters.json"))
out <- fluvgeo::record_study_terrain_metadata(p$INPUT,file.path(dirname(p$INPUT),"direct.gpkg"),
  p$EVENT_ID,p$VERTICAL_UNIT,p$VERTICAL_REFERENCE,p$EVIDENCE,p$ANALYST,
  file.path(dirname(p$INPUT),"direct.json"),file.path(root,"direct.html"))
a <- jsonlite::read_json(p$MANIFEST); b <- jsonlite::read_json(out$manifest)
normalize <- function(x) {
  x$created_at <- NULL
  x$artifacts[[1]]$metadata_evidence <- sub("^\\[[^]]+\\] ","",x$artifacts[[1]]$metadata_evidence)
  x
}
stopifnot(identical(normalize(a),normalize(b)),is.null(a$artifacts[[1]]$vertical_unit),
  identical(a$artifacts[[1]]$vertical_reference,p$VERTICAL_REFERENCE))
tables <- function(path) {
  x <- vapply(xml2::xml_find_all(xml2::read_html(path),".//table"),as.character,character(1))
  gsub("\\[[0-9]{4}-[^]]+Z\\] ","[assertion time] ",x)
}
stopifnot(identical(tables(p$OUTPUT),tables(out$report)))
before <- fluvgeo::read_study_context(p$INPUT); after <- fluvgeo::read_study_context(p$CONTEXT)
before$folder_manifest <- after$folder_manifest <- NULL; stopifnot(identical(before,after))
original <- jsonlite::read_json(fluvgeo::read_study_context(p$INPUT)$folder_manifest)
stopifnot(identical(a$event_links,original$event_links),identical(a$artifacts[-1],original$artifacts[-1]),
  identical(a$artifacts[[1]]$observed,original$artifacts[[1]]$observed),
  identical(a$artifacts[[1]]$sha256,original$artifacts[[1]]$sha256))
review <- fluvgeo::read_study_context_summary(p$CONTEXT)
stopifnot("VERTICAL_REFERENCE_UNKNOWN" %in% review$assessment$code)
jsonlite::write_json(list(direct_manifest_match=TRUE,direct_tables_match=TRUE,
  ids_links_other_artifacts_unchanged=TRUE,unprovided_units_remain_unknown=TRUE,
  metadata_is_synthetic=TRUE),file.path(root,"direct-evidence.json"),auto_unbox=TRUE,pretty=TRUE)
