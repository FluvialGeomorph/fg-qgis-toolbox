test_that("review and revision transport the selected report purpose", {
  withr::local_envvar(c(GDAL_DRIVER_PATH = NA, GDAL_DATA = NA, PROJ_LIB = NA, PROJ_DATA = NA))
  expect_true(rmarkdown::pandoc_available())
  root <- tempfile(); dir.create(root); withr::defer(unlink(root, recursive = TRUE))
  context <- fluvgeo::start_study_context(file.path(root, "draft.gpkg"), "Test study")$context
  original <- fluvgeo::read_study_context(context)
  before <- tools::md5sum(context)
  review <- system.file("rscripts", "fg_review_study_area.rsx", package = "fgqgis", mustWork = TRUE)
  edit <- system.file("rscripts", "fg_revise_study_area.rsx", package = "fgqgis", mustWork = TRUE)
  titles <- c("Terrain Development", "Define Study Area", "Study Area Staging Report")
  for (i in 0:2) {
    out <- run_rsx_fixture(review, list(INPUT = context, OUTPUT = file.path(root, paste0(i, ".html")), REPORT_VIEW = i))
    expect_match(paste(readLines(out$OUTPUT, warn = FALSE), collapse = ""), paste0("<title>", titles[i + 1L], "</title>"), fixed = TRUE)
    edited <- run_rsx_fixture(edit, list(INPUT = context, CONTEXT = file.path(root, paste0("edit", i, ".gpkg")),
      OUTPUT = file.path(root, paste0("edit", i, ".html")), REPORT_VIEW = i, NEW_NAME = "", ADD_NOTE = "Scope note"))
    expect_match(paste(readLines(edited$OUTPUT, warn = FALSE), collapse = ""), paste0("<title>", titles[i + 1L], "</title>"), fixed = TRUE)
    expect_identical(fluvgeo::read_study_context(edited$CONTEXT)$study_area, original$study_area)
  }
  for (bad in list(-1, 3, NA_integer_, "definition", 0.5, TRUE, c(0, 1))) {
    expect_error(run_rsx_fixture(review, list(INPUT = context, OUTPUT = file.path(root, "bad.html"), REPORT_VIEW = bad)), "REPORT_VIEW")
    expect_false(file.exists(file.path(root, "bad.html")))
  }
  expect_identical(tools::md5sum(context), before)
})

test_that("reference review transport is explicit and empty drafts remain reviewable", {
  withr::local_envvar(c(GDAL_DRIVER_PATH = NA, GDAL_DATA = NA, PROJ_LIB = NA, PROJ_DATA = NA))
  root <- tempfile(); dir.create(root); withr::defer(unlink(root, recursive = TRUE))
  context <- fluvgeo::start_study_context(file.path(root, "draft.gpkg"), "Reference review draft")$context
  before <- tools::md5sum(context)
  script <- system.file("rscripts", "fg_review_study_area.rsx", package = "fgqgis", mustWork = TRUE)
  for (view in 0:2) {
    out <- run_rsx_fixture(script, list(INPUT = context, REPORT_VIEW = view,
      TERRAIN_REFERENCES = TRUE, OUTPUT = file.path(root, paste0(view, ".html"))))
    expect_identical(out$arguments$terrain_references, TRUE)
    expect_true(file.exists(out$OUTPUT))
    expect_true(is.null(fluvgeo::read_study_context_summary(context)$terrain_review))
  }
  out <- run_rsx_fixture(script, list(INPUT = context, TERRAIN_REFERENCES = FALSE,
    OUTPUT = file.path(root, "off.html")))
  expect_false("terrain_references" %in% names(out$arguments))
  for (bad in list(NA, NULL, 1, "TRUE", logical(), c(TRUE, FALSE))) {
    expect_error(run_rsx_fixture(script, list(INPUT = context,
      TERRAIN_REFERENCES = bad, OUTPUT = file.path(root, "bad.html"))), "TERRAIN_REFERENCES")
    expect_false(file.exists(file.path(root, "bad.html")))
  }
  expect_identical(tools::md5sum(context), before)
})

test_that("an older backend retains default reporting but refuses the opt-in", {
  withr::local_envvar(c(GDAL_DRIVER_PATH = NA, GDAL_DATA = NA, PROJ_LIB = NA, PROJ_DATA = NA))
  testthat::local_mocked_bindings(study_context_report = function(dsn, output_file, purpose) output_file,
    .package = "fluvgeo")
  script <- system.file("rscripts", "fg_review_study_area.rsx", package = "fgqgis", mustWork = TRUE)
  for (inputs in list(list(), list(TERRAIN_REFERENCES = FALSE))) {
    out <- run_rsx_fixture(script, c(list(INPUT = "unused.gpkg", OUTPUT = "not-written.html"), inputs))
    expect_identical(out$OUTPUT, "not-written.html")
  }
  expect_error(run_rsx_fixture(script, list(INPUT = "unused.gpkg", OUTPUT = "not-written.html",
    TERRAIN_REFERENCES = TRUE)), "compatible fluvgeo installation with terrain-reference review")
})
