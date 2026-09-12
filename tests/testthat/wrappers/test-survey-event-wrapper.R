test_that("acquired-event wrapper preserves the retained years and existing identities", {
  root <- tempfile(); dir.create(root); withr::defer(unlink(root,recursive=TRUE))
  dsn <- fluvgeo::start_study_context(file.path(root,"draft.gpkg"),"Fixture")$context
  dsn <- fluvgeo::define_study_streams(dsn,file.path(root,"streams.gpkg"),
    data.frame(stream_name="Little Papillion Creek"),add_note="Fixture")$context
  dsn <- fluvgeo::add_study_reaches(dsn,file.path(root,"reaches.gpkg"),
    data.frame(reach_name="Cole Creek R1",stream_id=fluvgeo::read_study_context(dsn)$streams$stream_id),add_note="Fixture")$context
  id <- fluvgeo::read_study_context(dsn)$reaches$reach_id
  script <- system.file("rscripts","fg_record_survey_event.rsx",package="fgqgis",mustWork=TRUE)
  withr::local_envvar(c(GDAL_DRIVER_PATH=NA,GDAL_DATA=NA,PROJ_LIB=NA,PROJ_DATA=NA))
  previous <- NULL
  for (year in c(2006L,2010L,2016L)) {
    source <- paste0("y",year,"_R1.gdb")
    gdb <- system.file(paste0("extdata/",source),package="fluvgeodata",mustWork=TRUE)
    hashes <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
    expect_identical(unique(sf::st_read(gdb,layer="flowline",quiet=TRUE)$ReachName),"Cole Creek R1")
    p <- list(INPUT=dsn,REACH_ID=id,ACQUIRED_DATE=as.character(year),SOURCE_REFERENCE=source,
      EVIDENCE='User-confirmed year for "Cole Creek"; full date unknown.',
      CONTEXT=file.path(root,paste0(year,".gpkg")),OUTPUT=file.path(root,paste0(year,".html")))
    run_rsx_fixture(script,p)
    actual <- fluvgeo::read_study_context(p$CONTEXT)
    direct <- fluvgeo::record_study_survey_event(dsn,file.path(root,paste0("direct-",year,".gpkg")),
      id,as.character(year),source,p$EVIDENCE)
    compare <- fluvgeo::read_study_context(direct$context)
    expect_false(tail(compare$survey_events$survey_event_id,1)==tail(actual$survey_events$survey_event_id,1))
    compare$survey_events$survey_event_id <- actual$survey_events$survey_event_id
    expect_equal(actual,compare)
    if (!is.null(previous)) expect_equal(head(actual$survey_events,-1),previous)
    previous <- actual$survey_events; dsn <- p$CONTEXT
    expect_identical(tools::md5sum(names(hashes)),hashes)
  }
  expect_identical(previous$survey_year,c(2006L,2010L,2016L))
  expect_true(all(is.na(previous$survey_month))); expect_true(all(is.na(previous$survey_day)))
  p$INPUT <- dsn; p$CONTEXT <- file.path(root,"never.gpkg"); p$OUTPUT <- file.path(root,"never.html")
  expect_error(run_rsx_fixture(script,p),"already recorded")
  expect_false(file.exists(p$CONTEXT)); expect_false(file.exists(p$OUTPUT))
})
