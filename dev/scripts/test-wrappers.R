# Run from the repository root using Rscript --vanilla.
# --workspace explicitly selects sibling source packages; otherwise use installed
# dependencies. No downloads, package installs, or QGIS profile changes occur.
root <- normalizePath(".", winslash = "/", mustWork = TRUE)
stopifnot(file.exists(file.path(root, "DESCRIPTION")))
.libPaths(c(file.path(root, "dev/local-library"), .libPaths()))
if ("--workspace" %in% commandArgs(trailingOnly = TRUE)) {
  for (package in c("fluvgeodata", "fluvgeo")) {
    pkgload::load_all(file.path(root, "..", package), quiet = TRUE)
  }
}
usethis::proj_set(root, force = TRUE)
library(testthat)
run_wrapper_tests <- function() {
  # testthis 1.1.1 calls documentSaveAll merely when rstudioapi is installed,
  # even outside RStudio. Scope this no-op to headless test execution only.
  # Do not edit testthis or rstudioapi installations.
  if (requireNamespace("rstudioapi", quietly = TRUE) && !rstudioapi::isAvailable()) {
    testthat::local_mocked_bindings(
      documentSaveAll = function(...) invisible(NULL), .package = "rstudioapi"
    )
  }
  # testthis::test_subdir does not source parent-directory helpers itself.
  pkgload::load_all(root, quiet = TRUE)
  sys.source(file.path(root, "tests/testthat/helper-rsx.R"), envir = globalenv())
  testthis::test_subdir("wrappers")
}
run_wrapper_tests()
