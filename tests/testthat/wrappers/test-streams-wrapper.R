test_that("initial Stream wrapper accepts explicit names or selected source rows", {
  root <- tempfile(); dir.create(root); withr::defer(unlink(root, recursive=TRUE))
  gdb <- system.file("extdata/NWO_Papillion_ColeCreek_Stream.gdb", package="fluvgeodata", mustWork=TRUE)
  hashes <- tools::md5sum(list.files(gdb, recursive=TRUE, full.names=TRUE))
  hucs <- sf::st_read(gdb, layer="Papillion_HUC12", quiet=TRUE)
  gpkg <- file.path(root, "areas.gpkg"); sf::st_write(hucs, gpkg, layer="chosen", quiet=TRUE)
  src <- fluvgeo::start_study_context(file.path(root, "draft.gpkg"), "NWO_Papillion")$context
  before <- tools::md5sum(c(src,gpkg))
  withr::local_envvar(c(GDAL_DRIVER_PATH=NA, GDAL_DATA=NA, PROJ_LIB=NA, PROJ_DATA=NA))
  script <- system.file("rscripts", "fg_define_study_streams.rsx", package="fgqgis", mustWork=TRUE)
  p <- list(INPUT=src, STREAM_NAMES="", STREAM_SOURCE=gpkg, SOURCE_LAYER="chosen", NAME_FIELD="Name",
    RATIONALE="User-confirmed HUC naming convention; fixture only.", CONTEXT=file.path(root,"streams.gpkg"), OUTPUT=file.path(root,"report.html"))
  out <- run_rsx_fixture(script,p)
  x <- fluvgeo::read_study_context(out$CONTEXT)
  expect_identical(x$streams$stream_name,hucs$Name)
  expect_identical(sf::st_as_binary(sf::st_geometry(x$streams)),sf::st_as_binary(sf::st_geometry(hucs)))
  expect_true(sf::st_crs(x$streams)==sf::st_crs(hucs))
  expect_identical(x$study_area,fluvgeo::read_study_context(src)$study_area)
  p$CONTEXT <- file.path(root,"named.gpkg"); p$OUTPUT <- file.path(root,"named.html")
  p$STREAM_SOURCE <- p$SOURCE_LAYER <- p$NAME_FIELD <- ""
  p$STREAM_NAMES <- "New Créek\n\nSecond Creek"
  named <- run_rsx_fixture(script,p)
  expect_identical(fluvgeo::read_study_context(named$CONTEXT)$streams$stream_name,c("New Créek","Second Creek"))
  expect_false(inherits(fluvgeo::read_study_context(named$CONTEXT)$streams,"sf"))
  p$CONTEXT <- file.path(root,"never.gpkg"); p$OUTPUT <- file.path(root,"never.html")
  p$STREAM_SOURCE <- gpkg
  expect_error(run_rsx_fixture(script,p),"not both")
  p$STREAM_NAMES <- ""
  expect_error(run_rsx_fixture(script,p),"together")
  expect_false(file.exists(p$CONTEXT)); expect_false(file.exists(p$OUTPUT))
  expect_identical(tools::md5sum(c(src,gpkg)),before)
  expect_identical(tools::md5sum(names(hashes)),hashes)
})
