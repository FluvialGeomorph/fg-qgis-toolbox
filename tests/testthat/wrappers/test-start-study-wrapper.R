test_that("starter adapter creates an empty draft and preserves an existing project", {
  withr::local_envvar(c(GDAL_DRIVER_PATH = NA, GDAL_DATA = NA, PROJ_LIB = NA, PROJ_DATA = NA))
  if (.Platform$OS.type == "windows") withr::local_locale(c(LC_CTYPE = "English_United States.utf8"))
  expect_true(rmarkdown::pandoc_available())
  # The retained archive is preservation evidence, not input required by a new study.
  archive <- system.file("extdata", "y2006_R1.gdb", package = "fluvgeodata", mustWork = TRUE)
  sources <- list.files(archive, full.names = TRUE, recursive = TRUE)
  source_hashes <- tools::md5sum(sources)
  root <- tempfile("New Cr\u00e9ek "); dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  script <- system.file("rscripts", "fg_start_study_area.rsx", package = "fgqgis", mustWork = TRUE)
  notes <- "Customer's question \u2014 \"draft\"\nC:\\terrain\\new"
  input <- list(STUDY_NAME = "New Creek \u2014 draft", SCOPE_NOTES = notes,
    CONTEXT = file.path(root, "study.gpkg"), OUTPUT = file.path(root, "report.html"))
  actual <- run_rsx_fixture(script, input)
  direct <- fluvgeo::start_study_context(file.path(root, "direct.gpkg"), input$STUDY_NAME, notes)
  actual_args <- fluvgeo::read_study_context(actual$CONTEXT)
  direct_args <- fluvgeo::read_study_context(direct$context)
  expect_false(identical(actual_args$study_area$study_area_id, direct_args$study_area$study_area_id))
  actual_args$study_area$study_area_id <- direct_args$study_area$study_area_id
  expect_identical(actual_args, direct_args)
  expect_true(file.exists(actual$OUTPUT))
  before <- tools::md5sum(c(input$CONTEXT, input$OUTPUT))
  expect_error(run_rsx_fixture(script, input), "already exists")
  expect_identical(tools::md5sum(c(input$CONTEXT, input$OUTPUT)), before)
  input$CONTEXT <- file.path(root, "blank.gpkg"); input$OUTPUT <- file.path(root, "blank.html")
  input$STUDY_NAME <- " "
  expect_error(run_rsx_fixture(script, input), "study_area_name")
  expect_false(file.exists(input$CONTEXT)); expect_false(file.exists(input$OUTPUT))
  input$STUDY_NAME <- "Another genuinely new study"; input$SCOPE_NOTES <- "  "
  blank <- run_rsx_fixture(script, input)
  expect_identical(fluvgeo::read_study_context(blank$CONTEXT)$analyst_notes, NA_character_)
  expect_identical(tools::md5sum(sources), source_hashes)
})
