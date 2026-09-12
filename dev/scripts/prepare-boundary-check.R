# Developer fixture/library only; no production installation or analyst trial.
args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 1L, !dir.exists(args[1]))
dir.create(args[1], recursive = TRUE)
root <- normalizePath(args[1], winslash = "/")
lib <- file.path(root, "r-library"); dir.create(lib)
for (repo in c("../fluvgeo", ".")) {
  status <- system2(file.path(R.home("bin"), "R.exe"),
    c("CMD", "INSTALL", "--no-multiarch", paste0("--library=", shQuote(lib)), shQuote(normalizePath(repo))),
    stdout = file.path(root, paste0(basename(normalizePath(repo)), "-install.log")), stderr = "")
  stopifnot(status == 0L)
}
.libPaths(c(lib, .libPaths()))
pkgload::load_all("../fluvgeodata", quiet = TRUE)
gdb <- system.file("extdata/NWO_Papillion_ColeCreek_Stream.gdb", package = "fluvgeodata", mustWork = TRUE)
before <- tools::md5sum(list.files(gdb, recursive = TRUE, full.names = TRUE))
hucs <- sf::st_read(gdb, layer = "Papillion_HUC12", quiet = TRUE)
boundary <- sf::st_sf(geometry = sf::st_union(hucs))
inputs <- file.path(root, "fixtures"); dir.create(inputs)
sf::st_write(boundary, file.path(inputs, "boundary.gpkg"), layer = "chosen_extent", quiet = TRUE)
sf::st_write(hucs, file.path(inputs, "boundary.gpkg"), layer = "uncombined_hucs", quiet = TRUE)
fluvgeo::start_study_context(file.path(inputs, "draft.gpkg"), "NWO_Papillion — development fixture",
  "Example only: original HUC union confirmed by analyst; no new customer approval.")
stopifnot(identical(tools::md5sum(names(before)), before))
jsonlite::write_json(list(fluvgeo = as.character(utils::packageVersion("fluvgeo")),
  fgqgis = as.character(utils::packageVersion("fgqgis")), source_files_unchanged = TRUE),
  file.path(root, "preparation.json"), auto_unbox = TRUE, pretty = TRUE)
