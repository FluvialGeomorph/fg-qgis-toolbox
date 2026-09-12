test_that("script discovery has no deployment side effects", {
  scripts <- qgis_scripts()
  expect_type(scripts, "character")
  expect_true(all(file.exists(scripts)))
  expect_false(any(grepl("fixtures", scripts, fixed = TRUE)))
  expect_setequal(basename(scripts), c("fg_review_stream_network.rsx", "fg_review_study_area.rsx", "fg_revise_study_area.rsx", "fg_start_study_area.rsx", "fg_set_study_boundary.rsx", "fg_define_study_streams.rsx", "fg_add_study_reaches.rsx", "fg_set_reach_areas.rsx", "fg_record_survey_event.rsx", "fg_associate_event_terrain.rsx", "fg_record_terrain_metadata.rsx"))
})

test_that("the thin-wrapper fixture meets the authoring contract", {
  expect_rsx_contract(test_path("fixtures", "check-flowline.rsx"))
})

test_that("all shipped scripts meet the same authoring contract", {
  expect_type(qgis_scripts(), "character")
  for (script in qgis_scripts()) expect_rsx_contract(script)
})

test_that("report choices declare an explicit default after their multiword labels", {
  for (name in c("fg_review_study_area.rsx", "fg_revise_study_area.rsx")) {
    lines <- readLines(system.file("rscripts", name, package = "fgqgis", mustWork = TRUE))
    expect_true("##REPORT_VIEW=enum Terrain Development;Define Study Area;Staging Report 0" %in% lines)
  }
})

test_that("the review wrapper explains a missing or incompatible backend", {
  for (script in qgis_scripts()) for (available in c(FALSE, TRUE)) {
    expect_error(run_rsx_fixture(script, list(
      requireNamespace = function(package, ...) package == "fgqgis" || available,
      getNamespaceExports = function(package) if (package == "fgqgis")
        "with_qgis_spatial_environment" else "an_old_api")),
      "compatible fluvgeo installation")
  }
})

test_that("the wrapper requires the packaged environment guard", {
  for (script in qgis_scripts()) expect_error(run_rsx_fixture(script, list(
    requireNamespace = function(...) FALSE)), "compatible fgqgis installation")
})
