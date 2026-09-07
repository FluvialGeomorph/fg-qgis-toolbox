test_that("script discovery has no deployment side effects", {
  scripts <- qgis_scripts()
  expect_type(scripts, "character")
  expect_true(all(file.exists(scripts)))
  expect_false(any(grepl("fixtures", scripts, fixed = TRUE)))
  # Intentional foundation state; change alongside the first reviewed algorithm.
  expect_length(scripts, 0L)
})

test_that("the thin-wrapper fixture meets the authoring contract", {
  expect_rsx_contract(test_path("fixtures", "check-flowline.rsx"))
})

test_that("all shipped scripts meet the same authoring contract", {
  expect_type(qgis_scripts(), "character")
  for (script in qgis_scripts()) expect_rsx_contract(script)
})
