test_that("terrain adapter links retained Cole Creek data without changing its values", {
  root <- tempfile(); dir.create(root); withr::defer(unlink(root,recursive=TRUE))
  ctx <- fluvgeo::start_study_context(file.path(root,"a.gpkg"),"Fixture")$context
  ctx <- fluvgeo::define_study_streams(ctx,file.path(root,"b.gpkg"),data.frame(stream_name="Cole Creek"),add_note="Fixture")$context
  ctx <- fluvgeo::add_study_reaches(ctx,file.path(root,"c.gpkg"),data.frame(reach_name="R1",
    stream_id=fluvgeo::read_study_context(ctx)$streams$stream_id),add_note="Fixture")$context
  ctx <- fluvgeo::record_study_survey_event(ctx,file.path(root,"events.gpkg"),
    fluvgeo::read_study_context(ctx)$reaches$reach_id,"2006","y2006_R1.gdb","Known year")$context
  gdb <- system.file("extdata/y2006_R1.gdb",package="fluvgeodata",mustWork=TRUE)
  hashes <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
  r <- terra::rast(gdb,subds="dem_2006_ft_50")
  tif <- file.path(root,"terrain.tif"); terra::writeRaster(r,tif,datatype=terra::datatype(r))
  expect_equal(terra::values(r),terra::values(terra::rast(tif)),tolerance=0)
  withr::local_envvar(c(GDAL_DRIVER_PATH=NA,GDAL_DATA=NA,PROJ_LIB=NA,PROJ_DATA=NA))
  p <- list(INPUT=ctx,EVENT_ID=fluvgeo::read_study_context(ctx)$survey_events$survey_event_id,TERRAIN=tif,
    EVIDENCE='Retained "2006" source; vertical reference unknown',ANALYST="Developer fixture",
    MANIFEST=file.path(root,"terrain.json"),CONTEXT=file.path(root,"linked.gpkg"),OUTPUT=file.path(root,"report.html"))
  script <- system.file("rscripts","fg_associate_event_terrain.rsx",package="fgqgis",mustWork=TRUE)
  run_rsx_fixture(script,p)
  direct <- fluvgeo::associate_study_terrain(ctx,file.path(root,"direct.gpkg"),p$EVENT_ID,tif,
    p$EVIDENCE,p$ANALYST,file.path(root,"direct.json"))
  a <- fluvgeo::read_study_context(p$CONTEXT); b <- fluvgeo::read_study_context(direct$context)
  a$folder_manifest <- b$folder_manifest <- NULL; expect_identical(a,b)
  am <- jsonlite::read_json(p$MANIFEST); bm <- jsonlite::read_json(direct$manifest)
  am$created_at <- bm$created_at <- NULL
  expect_false(identical(am$artifacts[[1]]$artifact_id,bm$artifacts[[1]]$artifact_id))
  bm$artifacts[[1]]$artifact_id <- am$artifacts[[1]]$artifact_id
  bm$event_links[[1]]$artifact_id <- am$event_links[[1]]$artifact_id
  expect_identical(am,bm)
  expect_identical(tools::md5sum(names(hashes)),hashes)
  review <- fluvgeo::read_study_context_summary(p$CONTEXT)
  expect_identical(review$event_artifacts$grid_status,"GRID_LOADED")
  expect_true("VERTICAL_REFERENCE_UNKNOWN" %in% review$assessment$code)
  p$INPUT <- p$CONTEXT; p$CONTEXT <- file.path(root,"never.gpkg")
  p$MANIFEST <- file.path(root,"never.json"); p$OUTPUT <- file.path(root,"never.html")
  expect_error(run_rsx_fixture(script,p),"already has a selected")
  expect_false(file.exists(p$MANIFEST)); expect_false(file.exists(p$CONTEXT))
})
