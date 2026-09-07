# Complete development dependencies after bootstrap; run from repository root.
.libPaths(c("dev/local-library", .libPaths()))
usethis::proj_set(".", force = TRUE)
testthis::use_test_subdir("wrappers", make_tester = FALSE)
for (package in c("testthis", "sf", "pkgload", "usethis", "roxygen2", "withr",
                  "rstudioapi")) {
  usethis::use_package(package, type = "Suggests")
}
d <- desc::desc(file = "DESCRIPTION")
d$set("Authors@R", read.dcf("../fluvgeo/DESCRIPTION")[1, "Authors@R"])
# Workspace source packages need not be installed to declare test dependencies.
d$set_dep("fluvgeo", "Suggests")
d$set_dep("fluvgeodata", "Suggests")
d$set("Remotes", "FluvialGeomorph/fluvgeo, FluvialGeomorph/fluvgeodata")
d$write()
