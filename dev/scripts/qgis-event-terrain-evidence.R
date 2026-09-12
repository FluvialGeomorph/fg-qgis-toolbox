args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args) %in% c(2L,3L))
suffix <- if (length(args)==3L) args[3] else ""
stopifnot(grepl("^[a-z0-9-]*$",suffix))
.libPaths(c(args[1],.libPaths())); Sys.unsetenv(c("GDAL_DRIVER_PATH","GDAL_DATA","PROJ_LIB","PROJ_DATA"))
root <- args[2]; entries <- jsonlite::read_json(file.path(root,"entries.json"))
hashes <- tools::md5sum(unique(unlist(lapply(entries,function(p) unlist(p[c("INPUT","TERRAIN","MANIFEST","CONTEXT","OUTPUT")])))))
original <- fluvgeo::read_study_context(entries[[1]]$INPUT)
for (i in seq_along(entries)) {
  p <- entries[[i]]; folder <- dirname(p$INPUT)
  direct <- fluvgeo::associate_study_terrain(p$INPUT,file.path(folder,paste0("direct-",suffix,i,".gpkg")),
    p$EVENT_ID,p$TERRAIN,p$EVIDENCE,p$ANALYST,file.path(folder,paste0("direct-",suffix,i,".json")))
  actual <- fluvgeo::read_study_context(p$CONTEXT); compare <- fluvgeo::read_study_context(direct$context)
  actual$folder_manifest <- compare$folder_manifest <- NULL
  stopifnot(identical(actual,compare),identical(actual,original))
  am <- jsonlite::read_json(p$MANIFEST); bm <- jsonlite::read_json(direct$manifest)
  am$created_at <- bm$created_at <- NULL
  stopifnot(am$artifacts[[i]]$artifact_id != bm$artifacts[[i]]$artifact_id)
  bm$artifacts[[i]]$artifact_id <- am$artifacts[[i]]$artifact_id
  bm$event_links[[i]]$artifact_id <- am$event_links[[i]]$artifact_id
  stopifnot(identical(am,bm))
  if (i>1) {
    old <- jsonlite::read_json(entries[[i-1]]$MANIFEST)
    stopifnot(identical(head(am$artifacts,-1),old$artifacts),identical(head(am$event_links,-1),old$event_links))
  }
}
p <- tail(entries,1)[[1]]
review <- fluvgeo::read_study_context_summary(p$CONTEXT)
stopifnot(all(review$event_artifacts$grid_status=="GRID_LOADED"),all(review$folder_inventory$artifacts$hash_verified),
  all(is.na(review$folder_inventory$artifacts$vertical_reference)),
  all(is.na(review$folder_inventory$artifacts$vertical_unit)),
  sum(review$assessment$code=="VERTICAL_REFERENCE_UNKNOWN")==3L)
reference <- file.path(root,paste0("direct",suffix,".html")); fluvgeo::study_context_report(p$CONTEXT,reference,"definition")
tables <- function(path) vapply(xml2::xml_find_all(xml2::read_html(path),".//table"),as.character,character(1))
stopifnot(identical(tables(p$OUTPUT),tables(reference)))
stopifnot(identical(tools::md5sum(names(hashes)),hashes))
jsonlite::write_json(list(direct_R_agreement=TRUE,identities_and_old_snapshots_preserved=TRUE,
  report_tables_match=TRUE,three_grids_loaded=TRUE,vertical_metadata_still_unknown=TRUE,
  source_outputs_unchanged=TRUE),file.path(root,paste0("direct-evidence",suffix,".json")),auto_unbox=TRUE,pretty=TRUE)
