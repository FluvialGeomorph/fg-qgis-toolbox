test_that("metadata adapter preserves retained masked terrain and displays asserted evidence", {
  root <- tempfile(); dir.create(root); withr::defer(unlink(root,recursive=TRUE))
  ctx <- fluvgeo::start_study_context(file.path(root,"a.gpkg"),"SYNTHETIC metadata test using retained raster")$context
  ctx <- fluvgeo::define_study_streams(ctx,file.path(root,"b.gpkg"),data.frame(stream_name="Stream"),add_note="Test")$context
  ctx <- fluvgeo::add_study_reaches(ctx,file.path(root,"c.gpkg"),data.frame(reach_name="R1",stream_id=fluvgeo::read_study_context(ctx)$streams$stream_id),add_note="Test")$context
  ctx <- fluvgeo::record_study_survey_event(ctx,file.path(root,"d.gpkg"),fluvgeo::read_study_context(ctx)$reaches$reach_id,"2006","Test","Synthetic")$context
  eid <- fluvgeo::read_study_context(ctx)$survey_events$survey_event_id
  gdb <- system.file("extdata/y2006_R1.gdb",package="fluvgeodata",mustWork=TRUE)
  hashes <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
  dem <- terra::rast(gdb,subds="dem_2006_ft_50"); tif <- file.path(root,"terrain.tif"); terra::writeRaster(dem,tif)
  ctx <- fluvgeo::associate_study_terrain(ctx,file.path(root,"linked.gpkg"),eid,tif,"Retained raster in synthetic metadata test","Fixture",file.path(root,"linked.json"))$context
  before <- tools::md5sum(list.files(root,full.names=TRUE))
  withr::local_envvar(c(GDAL_DRIVER_PATH=NA,GDAL_DATA=NA,PROJ_LIB=NA,PROJ_DATA=NA))
  p <- list(INPUT=ctx,EVENT_ID=eid,VERTICAL_UNIT="",VERTICAL_REFERENCE="SYNTHETIC TEST reference, not Cole Creek metadata",
    EVIDENCE='Test "assertion" only; no source datum established',ANALYST="Developer fixture",
    MANIFEST=file.path(root,"metadata.json"),CONTEXT=file.path(root,"metadata.gpkg"),OUTPUT=file.path(root,"report.html"))
  script <- system.file("rscripts","fg_record_terrain_metadata.rsx",package="fgqgis",mustWork=TRUE)
  run_rsx_fixture(script,p)
  direct <- fluvgeo::record_study_terrain_metadata(ctx,file.path(root,"direct.gpkg"),eid,"",p$VERTICAL_REFERENCE,
    p$EVIDENCE,p$ANALYST,file.path(root,"direct.json"),file.path(root,"direct.html"))
  a <- jsonlite::read_json(p$MANIFEST); b <- jsonlite::read_json(direct$manifest)
  a$created_at <- b$created_at <- NULL
  strip_time <- function(x) sub("^\\[[^]]+\\] ","",x)
  a$artifacts[[1]]$metadata_evidence <- strip_time(a$artifacts[[1]]$metadata_evidence)
  b$artifacts[[1]]$metadata_evidence <- strip_time(b$artifacts[[1]]$metadata_evidence)
  expect_identical(a,b)
  expect_null(a$artifacts[[1]]$vertical_unit)
  expect_identical(tools::md5sum(names(before)),before)
  expect_identical(tools::md5sum(names(hashes)),hashes)
  html <- xml2::xml_text(xml2::read_html(p$OUTPUT))
  expect_match(html,p$VERTICAL_REFERENCE,fixed=TRUE)
  expect_false(grepl("Terrain coverage review|Reach with finite data",html))
  expect_error(run_rsx_fixture(script,p),"Context destination already exists")
})
