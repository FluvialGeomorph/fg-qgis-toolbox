# Isolated developer fixture; continue the preceding saved event identities.
args <- commandArgs(trailingOnly=TRUE)
stopifnot(length(args)==2L,!file.exists(args[1]),file.exists(args[2]))
dir.create(args[1],recursive=TRUE); root <- normalizePath(args[1],winslash="/")
lib <- file.path(root,"r-library"); dir.create(lib)
for(repo in c("../fluvgeo",".")) {
  status <- system2(file.path(R.home("bin"),"R.exe"),
    c("CMD","INSTALL","--no-multiarch",paste0("--library=",shQuote(lib)),shQuote(normalizePath(repo))),
    stdout=file.path(root,paste0(basename(normalizePath(repo)),"-install.log")),stderr="")
  stopifnot(status==0L)
}
.libPaths(c(lib,.libPaths())); pkgload::load_all("../fluvgeodata",quiet=TRUE)
inputs <- file.path(root,"fixtures"); dir.create(inputs)
source_hash <- tools::md5sum(args[2]); stopifnot(file.copy(args[2],file.path(inputs,"study.gpkg")))
context <- fluvgeo::read_study_context(file.path(inputs,"study.gpkg"))
stopifnot(is.null(context$folder_manifest),is.null(context$network),nrow(context$survey_events)==3L)
years <- c(2006L,2010L,2016L); layers <- c("dem_2006_ft_50","dem_2010_ft_50","dem_2016_hydro_50")
stopifnot(identical(context$survey_events$survey_year,years))
dir.create(file.path(inputs,"terrain")); copies <- list()
for (i in seq_along(years)) {
  gdb <- system.file(paste0("extdata/y",years[i],"_R1.gdb"),package="fluvgeodata",mustWork=TRUE)
  hashes <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
  source <- terra::rast(gdb,subds=layers[i])
  target <- terra::writeRaster(source,file.path(inputs,"terrain",paste0(layers[i],".tif")),
    datatype=terra::datatype(source),gdal="COMPRESS=DEFLATE")
  before <- terra::values(source); after <- terra::values(target)
  stopifnot(identical(is.na(before),is.na(after)),identical(before[!is.na(before)],after[!is.na(before)]),
    identical(terra::res(source),terra::res(target)),
    identical(as.vector(terra::ext(source)),as.vector(terra::ext(target))),
    isTRUE(sf::st_crs(terra::crs(source))==sf::st_crs(terra::crs(target))),
    identical(tools::md5sum(names(hashes)),hashes))
  copies[[i]] <- list(year=years[i],layer=layers[i],source=basename(gdb),
    event_id=context$survey_events$survey_event_id[i],path=paste0("terrain/",layers[i],".tif"),
    exact_values=TRUE,exact_NoData=TRUE,grid_and_CRS=TRUE,source_unchanged=TRUE)
}
stopifnot(identical(tools::md5sum(args[2]),source_hash))
jsonlite::write_json(copies,file.path(inputs,"terrain-fixture.json"),auto_unbox=TRUE,pretty=TRUE)
