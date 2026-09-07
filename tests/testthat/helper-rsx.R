# This checks our plain-R wrapper conventions, not the QGIS parser/runtime.
expect_rsx_contract <- function(path) {
  lines <- readLines(path, warn = FALSE)
  expect_equal(sum(grepl("^##fg_[a-z0-9_]+=name$", lines)), 1L)
  expect_true("##FluvialGeomorph=group" %in% lines)
  expect_equal(sum(grepl("^##.+=display_name$", lines)), 1L)
  expect_true(any(grepl("^#' ALG_DESC: .+", lines)))
  expect_true(any(grepl("^#' ALG_VERSION: .+", lines)))
  expect_false(any(grepl("github_install|load_.*_using_rgdal|^>", lines)))
  expect_false(any(grepl("install\\.packages\\s*\\(|setwd\\s*\\(", lines)))
  expect_true(any(grepl("fluvgeo::", lines, fixed = TRUE)))
  metadata <- sub("^##", "", grep("^##.*=", lines, value = TRUE))
  parameters <- sub("=.*", "", metadata[!grepl("=(name|display_name|group)$", metadata)])
  help <- sub("^#' ([^:]+):.*", "\\1", grep("^#' [^:]+:", lines, value = TRUE))
  expect_true(all(parameters %in% help))
  expect_no_error(parse(path))
}

run_rsx_fixture <- function(path, inputs) {
  # Provider metadata/help are R comments. No parameter conversion is emulated.
  # Restrict fixtures to ordinary R; provider-only command syntax needs QGIS tests.
  environment <- list2env(inputs, parent = globalenv())
  sys.source(path, envir = environment)
  environment
}
