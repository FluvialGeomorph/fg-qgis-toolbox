args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==2L)
.libPaths(c(args[1],.libPaths())); Sys.unsetenv(c("GDAL_DRIVER_PATH","GDAL_DATA","PROJ_LIB","PROJ_DATA"))
root <- args[2]; p <- jsonlite::read_json(file.path(root,"parameters.json"),simplifyVector=TRUE)
final <- jsonlite::read_json(file.path(root,"final-parameters.json"),simplifyVector=TRUE)
folder <- dirname(p$INPUT)
paths <- c(p$CONTEXT,file.path(folder,"event 2010.gpkg"),final$CONTEXT)
html <- c(p$OUTPUT,file.path(root,"event 2010.html"),final$OUTPUT)
hashes <- tools::md5sum(c(p$INPUT,paths,html))
src <- fluvgeo::read_study_context(p$INPUT); current <- p$INPUT; previous <- NULL
years <- c(2006L,2010L,2016L)
for (i in seq_along(years)) {
  actual <- fluvgeo::read_study_context(paths[i])
  direct <- fluvgeo::record_study_survey_event(current,file.path(folder,paste0("direct-",years[i],".gpkg")),
    p$REACH_ID,as.character(years[i]),paste0("y",years[i],"_R1.gdb"),p$EVIDENCE)
  compare <- fluvgeo::read_study_context(direct$context)
  stopifnot(tail(compare$survey_events$survey_event_id,1)!=tail(actual$survey_events$survey_event_id,1))
  compare$survey_events$survey_event_id[i] <- actual$survey_events$survey_event_id[i]
  stopifnot(isTRUE(all.equal(actual,compare)))
  if (i>1) stopifnot(isTRUE(all.equal(head(actual$survey_events,-1),previous)))
  other <- actual; other$survey_events <- NULL; stopifnot(identical(other,src))
  previous <- actual$survey_events; current <- paths[i]
}
stopifnot(identical(previous$survey_year,years),all(is.na(previous$survey_month)),
  all(is.na(previous$survey_day)),is.integer(previous$survey_month),
  identical(previous$reach_id,rep(p$REACH_ID,3)),length(unique(previous$survey_event_id))==3L)
reference <- file.path(root,"direct.html")
fluvgeo::study_context_report(final$CONTEXT,reference,"definition")
tables <- function(path) vapply(xml2::xml_find_all(xml2::read_html(path),".//table"),as.character,character(1))
stopifnot(identical(tables(final$OUTPUT),tables(reference)))
images <- xml2::xml_attr(xml2::xml_find_all(xml2::read_html(final$OUTPUT),".//img"),"src")
embedded <- images[grepl("^data:image/png;base64,",images)]; stopifnot(length(embedded)==1L)
writeBin(openssl::base64_decode(sub("^data:image/png;base64,","",embedded)),file.path(root,"study-map.png"))
stopifnot(identical(tools::md5sum(names(hashes)),hashes))
jsonlite::write_json(list(direct_R_agreement=TRUE,prior_ids_and_context_preserved=TRUE,
  date_precision_preserved=TRUE,report_tables_match=TRUE,source_outputs_unchanged=TRUE,
  asset_linking_not_performed=TRUE),file.path(root,"direct-evidence.json"),auto_unbox=TRUE,pretty=TRUE)
