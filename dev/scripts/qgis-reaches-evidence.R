# Compare independent R and actual QGIS runs without equating generated UUIDs.
args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==2L)
.libPaths(c(args[1],.libPaths())); Sys.unsetenv(c("GDAL_DRIVER_PATH","GDAL_DATA","PROJ_LIB","PROJ_DATA"))
root <- args[2]; p <- jsonlite::read_json(file.path(root,"parameters.json"),simplifyVector=TRUE)
hashes <- tools::md5sum(c(p$INPUT,p$REACH_SOURCE,p$CONTEXT,p$OUTPUT))
source <- fluvgeo::read_study_context(p$INPUT); actual <- fluvgeo::read_study_context(p$CONTEXT)
rows <- sf::st_read(p$REACH_SOURCE,layer=p$SOURCE_LAYER,quiet=TRUE)
parent <- source$streams$stream_id[source$streams$stream_name=="Little Papillion Creek"]
stopifnot(length(parent)==1L, identical(actual$reaches$reach_name,"Cole Creek R1"),
  identical(actual$reaches$stream_id,parent), !inherits(actual$reaches,"sf"),
  identical(actual$analyst_notes,paste(source$analyst_notes,paste0("Reaches added (1): ",p$RATIONALE),sep="\n\n")))
unchanged <- actual; unchanged$reaches <- NULL; unchanged$analyst_notes <- source$analyst_notes
stopifnot(identical(unchanged,source), is.null(actual$survey_events))
direct <- fluvgeo::add_study_reaches(p$INPUT,file.path(dirname(p$INPUT),"direct.gpkg"),rows,
  name_column=p$NAME_FIELD,parent_column=p$PARENT_FIELD,parent_key="stream_name",add_note=p$RATIONALE)
direct_args <- fluvgeo::read_study_context(direct$context)
stopifnot(!any(direct_args$reaches$reach_id %in% actual$reaches$reach_id))
direct_args$reaches$reach_id <- actual$reaches$reach_id
stopifnot(isTRUE(all.equal(actual,direct_args)))
reference <- file.path(root,"direct.html")
fluvgeo::study_context_report(p$CONTEXT,reference,"definition")
tables <- function(path) vapply(xml2::xml_find_all(xml2::read_html(path),".//table"),as.character,character(1))
stopifnot(identical(tables(p$OUTPUT),tables(reference)))
named <- fluvgeo::read_study_context(file.path(dirname(p$INPUT),"names only.gpkg"))
stopifnot(identical(named$reaches$reach_name,c("Cole Creek R1","Additional Reach — test only")),
  identical(named$reaches$reach_id[1],actual$reaches$reach_id),
  identical(named$reaches$stream_id,rep(parent,2)),
  !inherits(named$reaches,"sf"),is.null(named$survey_events))
images <- xml2::xml_attr(xml2::xml_find_all(xml2::read_html(p$OUTPUT),".//img"),"src")
embedded <- images[grepl("^data:image/png;base64,",images)]; stopifnot(length(embedded)==1L)
writeBin(openssl::base64_decode(sub("^data:image/png;base64,","",embedded)),file.path(root,"reaches-map.png"))
stopifnot(identical(tools::md5sum(names(hashes)),hashes))
jsonlite::write_json(list(source_and_existing_outputs_unchanged=TRUE,
  explicit_parent_and_new_local_id=TRUE, other_context_unchanged=TRUE,
  direct_R_agreement=TRUE, progressive_names_only_preserves_first_reach=TRUE,
  no_area_or_acquisition_invented=TRUE),file.path(root,"direct-evidence.json"),auto_unbox=TRUE,pretty=TRUE)
