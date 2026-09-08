test_that("script discovery has no deployment side effects", {
  scripts <- qgis_scripts()
  expect_type(scripts, "character")
  expect_true(all(file.exists(scripts)))
  expect_false(any(grepl("fixtures", scripts, fixed = TRUE)))
  expect_identical(basename(scripts), "fg_review_stream_network.rsx")
})

test_that("the thin-wrapper fixture meets the authoring contract", {
  expect_rsx_contract(test_path("fixtures", "check-flowline.rsx"))
})

test_that("all shipped scripts meet the same authoring contract", {
  expect_type(qgis_scripts(), "character")
  for (script in qgis_scripts()) expect_rsx_contract(script)
})

test_that("the review wrapper explains a missing or incompatible backend", {
  script <- qgis_scripts()[[1]]
  for (available in c(FALSE, TRUE)) {
    expect_error(run_rsx_fixture(script, list(
      requireNamespace = function(...) available,
      getNamespaceExports = function(...) "an_old_api")),
      "compatible fluvgeo installation")
  }
})
