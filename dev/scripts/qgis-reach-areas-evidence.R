args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==2L)
.libPaths(c(args[1],.libPaths())); Sys.unsetenv(c("GDAL_DRIVER_PATH","GDAL_DATA","PROJ_LIB","PROJ_DATA"))
root <- args[2]; p <- jsonlite::read_json(file.path(root,"parameters.json"),simplifyVector=TRUE)
hashes <- tools::md5sum(c(p$INPUT,p$AREAS,p$CONTEXT,p$OUTPUT))
areas <- sf::st_read(p$AREAS,layer=p$AREA_LAYER,quiet=TRUE)
src <- fluvgeo::read_study_context(p$INPUT); actual <- fluvgeo::read_study_context(p$CONTEXT)
stopifnot(identical(sf::st_drop_geometry(actual$reaches),src$reaches),
  identical(sf::st_as_binary(sf::st_geometry(actual$reaches)),sf::st_as_binary(sf::st_geometry(areas))),
  isTRUE(sf::st_crs(actual$reaches)==sf::st_crs(areas)))
other <- actual; other$reaches <- src$reaches; other$analyst_notes <- src$analyst_notes
stopifnot(identical(other,src))
direct <- fluvgeo::set_study_reach_areas(p$INPUT,file.path(dirname(p$INPUT),"direct.gpkg"),
  areas,id_column=p$ID_FIELD,add_note=p$RATIONALE,report_file=file.path(root,"direct.html"))
stopifnot(isTRUE(all.equal(actual,fluvgeo::read_study_context(direct$context))))
tables <- function(path) vapply(xml2::xml_find_all(xml2::read_html(path),".//table"),as.character,character(1))
stopifnot(identical(tables(p$OUTPUT),tables(direct$report)))
revised <- fluvgeo::read_study_context(file.path(dirname(p$INPUT),"revised.gpkg"))
stopifnot(identical(revised$reaches,actual$reaches),
  grepl("Reach areas revised (1)",revised$analyst_notes,fixed=TRUE))
source <- jsonlite::read_json(file.path(dirname(p$INPUT),"reach-area-source.json"),simplifyVector=TRUE)
b <- unname(sf::st_bbox(actual$reaches))
# JSON's printed bounds can round at the nanometre level; WKB equality above
# remains exact. This tolerance applies only to the human-readable metadata copy.
stopifnot(max(abs(as.numeric(b)-as.numeric(source$extent[c(1,3,2,4)]))) < 1e-8,
  sf::st_crs(actual$reaches)==sf::st_crs(source$crs_wkt))
images <- xml2::xml_attr(xml2::xml_find_all(xml2::read_html(p$OUTPUT),".//img"),"src")
embedded <- images[grepl("^data:image/png;base64,",images)]; stopifnot(length(embedded)==1L)
writeBin(openssl::base64_decode(sub("^data:image/png;base64,","",embedded)),file.path(root,"reach-area-map.png"))
stopifnot(identical(tools::md5sum(names(hashes)),hashes))
jsonlite::write_json(list(direct_R_agreement=TRUE,source_outputs_unchanged=TRUE,
  identities_parentage_other_context_preserved=TRUE,native_geometry_crs_preserved=TRUE,
  dem_rectangular_extent_matches=TRUE),file.path(root,"direct-evidence.json"),auto_unbox=TRUE,pretty=TRUE)
