test_that("the boundary wrapper imports explicit geometry without adopting its attributes", {
  root <- tempfile(); dir.create(root); withr::defer(unlink(root, recursive = TRUE))
  data_root <- system.file("extdata", package = "fluvgeodata", mustWork = TRUE)
  gdb <- list.files(data_root, "NWO_Papillion_ColeCreek_Stream.gdb", recursive = TRUE, full.names = TRUE, include.dirs = TRUE)
  expect_length(gdb, 1L)
  before <- tools::md5sum(list.files(gdb, recursive = TRUE, full.names = TRUE))
  hucs <- sf::st_read(gdb, layer = "Papillion_HUC12", quiet = TRUE)
  # The analyst explicitly confirmed this union in the Papillion fixture.
  boundary <- sf::st_sf(source_label = "Do not replace the Study Area name", geometry = sf::st_union(hucs))
  gpkg <- file.path(root, "chosen boundary.gpkg")
  sf::st_write(boundary, gpkg, layer = "chosen_extent", quiet = TRUE)
  input <- fluvgeo::start_study_context(file.path(root, "draft.gpkg"), "NWO_Papillion")$context
  hashes <- tools::md5sum(c(input, gpkg))
  # Prepare data using R's initialized GDAL resources; only the wrapper-body
  # probe clears overrides (it is not a fresh provider subprocess).
  withr::local_envvar(c(GDAL_DRIVER_PATH = NA, GDAL_DATA = NA, PROJ_LIB = NA, PROJ_DATA = NA))
  script <- system.file("rscripts", "fg_set_study_boundary.rsx", package = "fgqgis", mustWork = TRUE)
  params <- list(INPUT = input, BOUNDARY = gpkg, BOUNDARY_LAYER = "chosen_extent",
    RATIONALE = "Analyst-confirmed union of selected HUC12 areas; fixture only.",
    CONTEXT = file.path(root, "bound.gpkg"), OUTPUT = file.path(root, "report.html"))
  result <- run_rsx_fixture(script, params)
  direct <- fluvgeo::revise_study_context(input, file.path(root, "direct.gpkg"),
    add_note = params$RATIONALE, study_area_boundary = sf::st_read(gpkg, layer = "chosen_extent", quiet = TRUE))
  expect_equal(fluvgeo::read_study_context(result$CONTEXT), fluvgeo::read_study_context(direct$context))
  expect_identical(fluvgeo::read_study_context(result$CONTEXT)$study_area$study_area_name, "NWO_Papillion")
  expect_match(paste(readLines(result$OUTPUT, warn = FALSE), collapse = ""), "Working Study Area extent", fixed = TRUE)
  expect_error(run_rsx_fixture(script, params), "already exists")
  params$CONTEXT <- file.path(root, "never.gpkg"); params$OUTPUT <- file.path(root, "never.html")
  params$BOUNDARY_LAYER <- ""
  expect_error(run_rsx_fixture(script, params), "exact BOUNDARY_LAYER")
  params$BOUNDARY_LAYER <- "chosen_extent"; params$RATIONALE <- " "
  expect_error(run_rsx_fixture(script, params), "add_note")
  expect_false(file.exists(params$CONTEXT))
  expect_false(file.exists(params$OUTPUT))
  expect_identical(tools::md5sum(c(input, gpkg)), hashes)
  expect_identical(tools::md5sum(names(before)), before)
})
