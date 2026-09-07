# Explicit testthis suite, separate from fast package checks.
test_that("the wrapper agrees with fluvgeo on three retained Cole Creek events", {
  for (package in c("sf", "fluvgeo", "fluvgeodata")) {
    expect_true(requireNamespace(package, quietly = TRUE), info = package)
  }
  for (year in c(2006L, 2010L, 2016L)) {
    archive <- system.file("extdata", paste0("y", year, "_R1.gdb"),
                           package = "fluvgeodata", mustWork = TRUE)
    source_files <- list.files(archive, full.names = TRUE, recursive = TRUE)
    before <- tools::md5sum(source_files)
    original <- sf::st_read(archive, layer = "flowline", quiet = TRUE)
    expect_equal(nrow(original), 1L)
    expect_identical(original$ReachName, "Cole Creek R1")
    expect_false(is.na(sf::st_crs(original)))

    # A test-owned GeoPackage crosses the local storage boundary without
    # converting or accepting the archived project as a whole.
    gpkg <- tempfile(paste0("cole creek ", year, " "), fileext = ".gpkg")
    withr::defer(unlink(gpkg))
    sf::st_write(original, gpkg, layer = "flowline", quiet = TRUE)
    layer <- sf::st_read(gpkg, layer = "flowline", quiet = TRUE)
    expect_true(sf::st_crs(layer) == sf::st_crs(original))
    expect_equal(sf::st_coordinates(layer), sf::st_coordinates(original))
    expect_identical(sf::st_drop_geometry(layer), sf::st_drop_geometry(original))
    expect_true(fluvgeo::check_flowline(layer, step = "create_flowline"))

    fixture <- test_path("..", "fixtures", "check-flowline.rsx")
    result <- run_rsx_fixture(fixture, list(Layer = layer))
    expect_identical(result$Result, "valid")
    expect_identical(result$Layer, layer)
    invalid <- layer
    invalid$ReachName <- NULL
    expect_error(run_rsx_fixture(fixture, list(Layer = invalid)), "ReachName")
    expect_identical(tools::md5sum(source_files), before)
  }
})
