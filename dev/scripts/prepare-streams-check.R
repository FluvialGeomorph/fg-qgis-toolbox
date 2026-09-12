# New isolated development library and explicitly interpreted Papillion fixture.
args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==1L,!dir.exists(args[1]))
dir.create(args[1],recursive=TRUE); root <- normalizePath(args[1],winslash="/")
lib <- file.path(root,"r-library"); dir.create(lib)
for(repo in c("../fluvgeo",".")) {
  status <- system2(file.path(R.home("bin"),"R.exe"),
    c("CMD","INSTALL","--no-multiarch",paste0("--library=",shQuote(lib)),shQuote(normalizePath(repo))),
    stdout=file.path(root,paste0(basename(normalizePath(repo)),"-install.log")),stderr="")
  stopifnot(status==0L)
}
.libPaths(c(lib,.libPaths())); pkgload::load_all("../fluvgeodata",quiet=TRUE)
gdb <- system.file("extdata/NWO_Papillion_ColeCreek_Stream.gdb",package="fluvgeodata",mustWork=TRUE)
before <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
hucs <- sf::st_read(gdb,layer="Papillion_HUC12",quiet=TRUE)
inputs <- file.path(root,"fixtures"); dir.create(inputs)
sf::st_write(hucs,file.path(inputs,"stream areas.gpkg"),layer="selected_streams",quiet=TRUE)
# Separate fixture identity; do not edit the analyst's saved draft or prior trial.
draft <- fluvgeo::start_study_context(file.path(inputs,"named.gpkg"),"NWO_Papillion — development fixture",
  "Example only. Analyst-confirmed HUC names and segmentation, not a universal rule.")$context
fluvgeo::revise_study_context(draft,file.path(inputs,"draft.gpkg"),
  study_area_boundary=sf::st_sf(geometry=sf::st_union(hucs)),add_note="User-confirmed union of selected HUC12 areas.")
stopifnot(identical(tools::md5sum(names(before)),before))
