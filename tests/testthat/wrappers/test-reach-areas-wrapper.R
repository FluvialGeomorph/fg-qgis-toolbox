test_that("Reach areas wrapper copies an explicitly keyed retained DEM extent", {
  root <- tempfile(); dir.create(root); withr::defer(unlink(root,recursive=TRUE))
  gdb <- system.file("extdata/y2016_R1.gdb",package="fluvgeodata",mustWork=TRUE)
  hashes <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
  dem <- terra::rast(gdb,subds="dem_2016_hydro_50")
  e <- unname(as.vector(terra::ext(dem)))
  g <- sf::st_as_sfc(sf::st_bbox(c(xmin=e[1],ymin=e[3],xmax=e[2],ymax=e[4]),crs=sf::st_crs(terra::crs(dem))))
  draft <- fluvgeo::start_study_context(file.path(root,"draft.gpkg"),"Test")$context
  streams <- fluvgeo::define_study_streams(draft,file.path(root,"streams.gpkg"),
    data.frame(stream_name="Little Papillion Creek"),add_note="Test")$context
  sid <- fluvgeo::read_study_context(streams)$streams$stream_id
  src <- fluvgeo::add_study_reaches(streams,file.path(root,"reaches.gpkg"),
    data.frame(reach_name="Cole Creek R1",stream_id=sid),add_note="Test")$context
  areas <- sf::st_sf(reach_id=fluvgeo::read_study_context(src)$reaches$reach_id,geometry=g)
  source <- file.path(root,"areas.gpkg"); sf::st_write(areas,source,layer="extent",quiet=TRUE)
  input_hashes <- tools::md5sum(c(src,source))
  withr::local_envvar(c(GDAL_DRIVER_PATH=NA,GDAL_DATA=NA,PROJ_LIB=NA,PROJ_DATA=NA))
  p <- list(INPUT=src,AREAS=source,AREA_LAYER="extent",ID_FIELD="reach_id",RATIONALE="DEM extent candidate only",
    CONTEXT=file.path(root,"out.gpkg"),OUTPUT=file.path(root,"report.html"))
  script <- system.file("rscripts","fg_set_reach_areas.rsx",package="fgqgis",mustWork=TRUE)
  run_rsx_fixture(script,p)
  direct <- fluvgeo::set_study_reach_areas(src,file.path(root,"direct.gpkg"),areas,add_note=p$RATIONALE)
  expect_equal(fluvgeo::read_study_context(p$CONTEXT),fluvgeo::read_study_context(direct$context))
  expect_identical(sf::st_as_binary(sf::st_geometry(fluvgeo::read_study_context(p$CONTEXT)$reaches)),sf::st_as_binary(g))
  expect_true(file.exists(p$OUTPUT))
  p$CONTEXT <- file.path(root,"never.gpkg"); p$OUTPUT <- file.path(root,"never.html"); p$ID_FIELD <- "unknown"
  expect_error(run_rsx_fixture(script,p),"ID column")
  expect_false(file.exists(p$CONTEXT)); expect_false(file.exists(p$OUTPUT))
  expect_identical(tools::md5sum(c(src,source)),input_hashes)
  expect_identical(tools::md5sum(names(hashes)),hashes)
})
