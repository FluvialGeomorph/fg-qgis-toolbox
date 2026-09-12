test_that("Reach wrapper binds a retained name to an explicit saved Stream", {
  root <- tempfile(); dir.create(root); withr::defer(unlink(root,recursive=TRUE))
  gdb <- system.file("extdata/y2006_R1.gdb",package="fluvgeodata",mustWork=TRUE)
  before <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
  flow <- sf::st_read(gdb,layer="flowline",quiet=TRUE)
  expect_identical(unique(flow$ReachName),"Cole Creek R1")
  input <- fluvgeo::start_study_context(file.path(root,"draft.gpkg"),"Study")$context
  src <- fluvgeo::define_study_streams(input,file.path(root,"streams.gpkg"),
    data.frame(stream_name=c("Little Papillion Creek","Other Creek")),add_note="Fixture")$context
  source <- file.path(root,"inventory.gpkg")
  sf::st_write(data.frame(Name=unique(flow$ReachName),Stream="Little Papillion Creek"),source,layer="reaches",quiet=TRUE)
  hashes <- tools::md5sum(c(src,source))
  withr::local_envvar(c(GDAL_DRIVER_PATH=NA,GDAL_DATA=NA,PROJ_LIB=NA,PROJ_DATA=NA))
  script <- system.file("rscripts","fg_add_study_reaches.rsx",package="fgqgis",mustWork=TRUE)
  p <- list(INPUT=src,STREAM_NAME="",REACH_NAMES="",REACH_SOURCE=source,SOURCE_LAYER="reaches",
    NAME_FIELD="Name",PARENT_FIELD="Stream",RATIONALE="Retained R1; explicitly assigned parent.",
    CONTEXT=file.path(root,"reaches.gpkg"),OUTPUT=file.path(root,"report.html"))
  result <- run_rsx_fixture(script,p)
  x <- fluvgeo::read_study_context(result$CONTEXT)
  mixed <- p; mixed$STREAM_NAME <- "Little Papillion Creek"; mixed$REACH_NAMES <- "Other Reach"
  expect_error(run_rsx_fixture(script,mixed),"Choose names-only or source mode")
  expect_identical(x$reaches$reach_name,"Cole Creek R1")
  expect_identical(x$reaches$stream_id,x$streams$stream_id[1])
  p$INPUT <- result$CONTEXT; p$CONTEXT <- file.path(root,"again.gpkg"); p$OUTPUT <- file.path(root,"again.html")
  expect_error(run_rsx_fixture(script,p),"Duplicate Reach")
  p$REACH_SOURCE <- p$SOURCE_LAYER <- p$NAME_FIELD <- p$PARENT_FIELD <- ""
  p$STREAM_NAME <- "Other Creek"; p$REACH_NAMES <- 'R1\nR2 "draft"'
  second <- run_rsx_fixture(script,p); y <- fluvgeo::read_study_context(second$CONTEXT)
  expect_equal(y$reaches[1,],x$reaches)
  expect_identical(y$reaches$reach_name,c("Cole Creek R1","R1",'R2 "draft"'))
  expect_identical(y$reaches$stream_id[-1],rep(x$streams$stream_id[2],2))
  expect_null(y$survey_events)
  expect_identical(tools::md5sum(c(src,source)),hashes)
  expect_identical(tools::md5sum(names(before)),before)
})
