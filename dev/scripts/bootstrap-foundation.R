# One-time foundation generator; run from the repository root.
# Maintained content is edited separately, never overwritten by this script.
root <- normalizePath(".", winslash = "/", mustWork = TRUE)
stopifnot(basename(root) == "fg-qgis-toolbox")
if (!file.exists("DESCRIPTION")) {
  usethis::create_package(
    root,
    fields = list(
      Package = "fgqgis",
      Title = "FluvialGeomorph Tools for the QGIS R Processing Provider",
      Version = "0.0.0.9000",
      `Authors@R` = read.dcf("../fluvgeo/DESCRIPTION")[1, "Authors@R"],
      Description = paste(
        "Packages thin R script interfaces to FluvialGeomorph scientific",
        "workflows for the QGIS Processing R Provider. Provides development",
        "and testing infrastructure while keeping scientific methods in",
        "the fluvgeo backend."
      ),
      License = "CC0",
      URL = "https://github.com/FluvialGeomorph/fg-qgis-toolbox",
      BugReports = "https://github.com/FluvialGeomorph/fg-qgis-toolbox/issues"
    ),
    check_name = FALSE, rstudio = FALSE, open = FALSE
  )
}
usethis::proj_set(root, force = TRUE)
usethis::use_testthat(edition = 3, parallel = FALSE)
usethis::use_build_ignore(c("AGENTS.md", "dev", "LICENSE"))
usethis::use_git_ignore(c(".Rhistory", ".RData", ".Ruserdata",
                         "dev/local-library/", "dev/check-output/"))
if (!file.exists("dev/agentic-context.yml")) {
  pkgload::load_all(file.path(root, "../reproducibleai"), quiet = TRUE)
  reproducibleai::use_agentic_context(root, c("base", "r-package"))
}
