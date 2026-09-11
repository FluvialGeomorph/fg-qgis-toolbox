# Run from fg-qgis-toolbox after test-wrappers.R --workspace. Use a new output
# root, or --checks-only to refresh only this script's generated package checks.
args <- commandArgs(trailingOnly = TRUE)
checks_only <- length(args) == 2L && identical(args[2], "--checks-only")
stopifnot(length(args) == 1L || checks_only)
if (!checks_only) {
  stopifnot(!dir.exists(args[1]))
  dir.create(args[1], recursive = TRUE)
}
root <- normalizePath(args[1], winslash = "/", mustWork = TRUE)
if (!checks_only) {
  pkgload::load_all(".", quiet = TRUE)
  testthat::test_local(".", reporter = "summary", stop_on_failure = TRUE)
  pkgload::load_all("../fluvgeo", quiet = TRUE)
  # Synthetic prospective example, deliberately unrelated to an accepted study.
  demo <- fluvgeo::start_study_context(file.path(root, "new-study.gpkg"),
    "Example Creek - prospective study",
    paste("Illustrative new-project draft, not a customer-approved scope.",
      "Customer question: How has channel condition changed, and where should field review focus?",
      "Open decisions: study extent, Streams and Reach divisions, suitable comparison periods.",
      "No acquisition dates, boundary or terrain have been asserted.", sep = "\n\n"),
    report_file = file.path(root, "define-study-area.html"))
  jsonlite::write_json(demo, file.path(root, "demo.json"), auto_unbox = TRUE, pretty = TRUE)
  pkgload::load_all("../reproducibleai", quiet = TRUE)
  for (repo in c(".", "../fluvgeo")) {
    validation <- reproducibleai::validate_agentic_context(repo, strict = TRUE)
    print(validation)
    stopifnot(validation$valid)
  }
}
# Source-package checks are separate from actual QGIS execution. Do not update
# any installed production library or the earlier frozen analyst trial library.
Sys.setenv(`_R_CHECK_FORCE_SUGGESTS_` = "false")
for (repo in c(".", "../fluvgeo")) {
  name <- if (repo == ".") "fgqgis" else "fluvgeo"
  flags <- c("--no-manual", "--no-vignettes")
  if (name == "fluvgeo") flags <- c(flags, "--no-tests", "--no-examples")
  # These are pure-R packages. R CMD build avoids pkgbuild's unnecessary compiler
  # probe on this R 4.6 workstation; no Rtools installation is performed.
  repo <- normalizePath(repo, winslash = "/", mustWork = TRUE)
  version <- read.dcf(file.path(repo, "DESCRIPTION"))[1, "Version"]
  tarball <- file.path(root, paste0(name, "_", version, ".tar.gz"))
  build_log <- tempfile(paste0(name, "-build-"), fileext = ".log")
  built <- withr::with_dir(root, system2(file.path(R.home("bin"), "R.exe"),
    c("CMD", "build", shQuote(repo), "--no-build-vignettes", "--no-manual"),
    stdout = build_log, stderr = ""))
  file.copy(build_log, file.path(root, paste0(name, "-build.log")), overwrite = TRUE)
  stopifnot(built == 0L, file.exists(tarball))
  check_dir <- file.path(root, paste0(name, "-native-check"))
  dir.create(check_dir, showWarnings = FALSE)
  check_log <- tempfile(paste0(name, "-check-"), fileext = ".log")
  checked <- system2(file.path(R.home("bin"), "R.exe"),
    c("CMD", "check", flags, paste0("--output=", shQuote(check_dir)), shQuote(tarball)),
    stdout = check_log, stderr = "")
  file.copy(check_log, file.path(root, paste0(name, "-check-console.log")), overwrite = TRUE)
  lines <- readLines(file.path(check_dir, paste0(name, ".Rcheck"), "00check.log"), warn = FALSE)
  status <- grep("^Status:", lines, value = TRUE)
  print(status)
  jsonlite::write_json(list(exit_status = checked, status = status),
    file.path(root, paste0(name, "-check.json")), pretty = TRUE)
  stopifnot(checked == 0L, length(status) == 1L, !grepl("ERROR|WARNING", status))
}
