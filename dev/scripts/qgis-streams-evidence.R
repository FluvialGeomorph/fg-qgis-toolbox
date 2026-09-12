# Compare output without treating independently generated Stream UUIDs as equal.
args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==2L)
.libPaths(c(args[1],.libPaths())); Sys.unsetenv(c("GDAL_DRIVER_PATH","GDAL_DATA","PROJ_LIB","PROJ_DATA"))
root <- args[2]; p <- jsonlite::read_json(file.path(root,"parameters.json"),simplifyVector=TRUE)
hashes <- tools::md5sum(c(p$INPUT,p$STREAM_SOURCE,p$CONTEXT,p$OUTPUT))
source <- fluvgeo::read_study_context(p$INPUT); actual <- fluvgeo::read_study_context(p$CONTEXT)
areas <- sf::st_read(p$STREAM_SOURCE,layer=p$SOURCE_LAYER,quiet=TRUE)
stopifnot(identical(actual$study_area,source$study_area),
  identical(actual$streams$stream_name,areas[[p$NAME_FIELD]]),
  length(unique(actual$streams$stream_id))==nrow(areas),
  identical(actual$streams$study_area_id,rep(source$study_area$study_area_id,nrow(areas))),
  identical(sf::st_as_binary(sf::st_geometry(actual$streams)),sf::st_as_binary(sf::st_geometry(areas))),
  isTRUE(sf::st_crs(actual$streams)==sf::st_crs(areas)),
  identical(actual$analyst_notes,paste(source$analyst_notes,paste0("Initial Streams defined (",nrow(areas),"): ",p$RATIONALE),sep="\n\n")))
unchanged <- actual; unchanged$streams <- NULL; unchanged$analyst_notes <- source$analyst_notes
stopifnot(identical(unchanged,source))
direct <- fluvgeo::define_study_streams(p$INPUT,file.path(dirname(p$INPUT),"direct.gpkg"),areas,p$NAME_FIELD,p$RATIONALE)
direct_args <- fluvgeo::read_study_context(direct$context)
stopifnot(!any(direct_args$streams$stream_id %in% actual$streams$stream_id))
direct_args$streams$stream_id <- actual$streams$stream_id
stopifnot(isTRUE(all.equal(actual,direct_args)))
reference <- file.path(root,"direct.html")
fluvgeo::study_context_report(p$CONTEXT,reference,"definition")
tables <- function(path) vapply(xml2::xml_find_all(xml2::read_html(path),".//table"),as.character,character(1))
stopifnot(identical(tables(p$OUTPUT),tables(reference)))
named <- fluvgeo::read_study_context(file.path(dirname(p$INPUT),"names only.gpkg"))
stopifnot(identical(named$streams$stream_name,c("New Créek",'Second "Creek"')),
  !inherits(named$streams,"sf"),!inherits(named$study_area,"sf"),is.null(named$reaches),is.null(named$survey_events))
images <- xml2::xml_attr(xml2::xml_find_all(xml2::read_html(p$OUTPUT),".//img"),"src")
embedded <- images[grepl("^data:image/png;base64,",images)]; stopifnot(length(embedded)==1L)
writeBin(openssl::base64_decode(sub("^data:image/png;base64,","",embedded)),file.path(root,"streams-map.png"))
stopifnot(identical(tools::md5sum(names(hashes)),hashes))
jsonlite::write_json(list(source_and_existing_outputs_unchanged=TRUE, native_geometry_crs=TRUE,
  names_parent_and_unique_local_ids=TRUE, other_context_unchanged=TRUE, direct_R_agreement=TRUE,
  names_only_without_boundary_or_acquisition=TRUE),file.path(root,"direct-evidence.json"),auto_unbox=TRUE,pretty=TRUE)
