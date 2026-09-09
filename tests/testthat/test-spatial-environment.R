test_that("no overrides preserve evaluation, visibility and caller assignments", {
  withr::local_envvar(c(GDAL_DRIVER_PATH = NA, GDAL_DATA = "", PROJ_LIB = NA,
                       PROJ_DATA = NA, OSGEO4W_ROOT = NA))
  expect_identical(with_qgis_spatial_environment(42L), 42L)
  expect_false(withVisible(with_qgis_spatial_environment(invisible(42L)))$visible)
  with_qgis_spatial_environment(answer <- 3L)
  expect_identical(answer, 3L)
  expect_identical(Sys.getenv("GDAL_DATA"), "")
})

test_that("only identified OSGeo4W overrides are cleared and restored", {
  root <- withr::local_tempdir()
  dir.create(file.path(root, "plugins"))
  dir.create(file.path(root, "proj"))
  keys <- c("GDAL_DRIVER_PATH", "GDAL_DATA", "PROJ_LIB", "PROJ_DATA")
  withr::local_envvar(c(OSGEO4W_ROOT = root,
    GDAL_DRIVER_PATH = file.path(root, "plugins"), GDAL_DATA = "",
    PROJ_LIB = NA, PROJ_DATA = file.path(root, "proj")))
  local_mocked_bindings(.fgqgis_loaded_spatial = function() character(), .package = "fgqgis")
  before <- Sys.getenv(keys, unset = NA_character_)
  expect_message(with_qgis_spatial_environment({
    expect_identical(Sys.getenv("GDAL_DRIVER_PATH", unset = NA_character_), NA_character_)
    expect_identical(Sys.getenv("PROJ_DATA", unset = NA_character_), NA_character_)
    expect_identical(Sys.getenv("GDAL_DATA"), "")
  }), "Using R's spatial resources")
  expect_identical(Sys.getenv(keys, unset = NA_character_), before)
  expect_message(expect_error(with_qgis_spatial_environment(stop("backend error")),
                              "backend error"), "Using R's spatial resources")
  expect_identical(Sys.getenv(keys, unset = NA_character_), before)
})

test_that("custom, mixed, nonexistent and prefix-sibling paths are not discarded", {
  root <- withr::local_tempdir()
  owned <- file.path(root, "osgeo")
  sibling <- file.path(root, "osgeo-other")
  dir.create(owned); dir.create(sibling)
  withr::local_envvar(c(OSGEO4W_ROOT = owned, GDAL_DATA = NA,
                       PROJ_LIB = NA, PROJ_DATA = NA, GDAL_DRIVER_PATH = NA))
  for (value in c(sibling, file.path(owned, "missing"),
                  paste0(owned, .Platform$path.sep),
                  paste(owned, sibling, sep = .Platform$path.sep))) {
    Sys.setenv(GDAL_DRIVER_PATH = value)
    expect_error(with_qgis_spatial_environment(stop("must not run")), "Unrecognized spatial")
    expect_identical(Sys.getenv("GDAL_DRIVER_PATH"), value)
  }
  Sys.setenv(GDAL_DRIVER_PATH = owned)
  Sys.unsetenv("OSGEO4W_ROOT")
  expect_error(with_qgis_spatial_environment(stop("must not run")), "Unrecognized spatial")
})

test_that("cached spatial state cannot be described as newly isolated", {
  root <- withr::local_tempdir()
  withr::local_envvar(c(OSGEO4W_ROOT = root, GDAL_DRIVER_PATH = root,
                       GDAL_DATA = NA, PROJ_LIB = NA, PROJ_DATA = NA))
  local_mocked_bindings(.fgqgis_loaded_spatial = function() "sf", .package = "fgqgis")
  expect_error(with_qgis_spatial_environment(stop("must not run")), "already loaded")
  expect_identical(Sys.getenv("GDAL_DRIVER_PATH"), root)
})
