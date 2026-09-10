test_that("script discovery has no deployment side effects", {
  scripts <- qgis_scripts()
  expect_type(scripts, "character")
  expect_true(all(file.exists(scripts)))
  expect_false(any(grepl("fixtures", scripts, fixed = TRUE)))
  expect_setequal(basename(scripts), c("fg_review_stream_network.rsx", "fg_review_study_area.rsx", "fg_revise_study_area.rsx"))
})

test_that("the thin-wrapper fixture meets the authoring contract", {
  expect_rsx_contract(test_path("fixtures", "check-flowline.rsx"))
})

test_that("all shipped scripts meet the same authoring contract", {
  expect_type(qgis_scripts(), "character")
  for (script in qgis_scripts()) expect_rsx_contract(script)
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
