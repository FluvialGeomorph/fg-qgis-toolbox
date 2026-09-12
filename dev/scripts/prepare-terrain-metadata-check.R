# Copy a linked fixture unchanged; actual metadata remains unknown in the clean report.
args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==2L,!file.exists(args[1]),file.exists(args[2]))
dir.create(args[1],recursive=TRUE); root <- normalizePath(args[1],winslash="/")
lib <- file.path(root,"r-library"); dir.create(lib)
for (repo in c("../fluvgeo",".")) {
  status <- system2(file.path(R.home("bin"),"R.exe"),c("CMD","INSTALL","--no-multiarch",paste0("--library=",shQuote(lib)),shQuote(normalizePath(repo))))
  stopifnot(status==0L)
}
.libPaths(c(lib,.libPaths()))
source <- normalizePath(args[2],winslash="/"); files <- list.files(dirname(source),full.names=TRUE)
before <- tools::md5sum(list.files(dirname(source),recursive=TRUE,full.names=TRUE))
dest <- file.path(root,"fixtures"); dir.create(dest); stopifnot(all(file.copy(files,dest,recursive=TRUE)))
context <- file.path(dest,basename(source))
fluvgeo::study_context_report(context,file.path(root,"define-study-area.html"),"definition")
stopifnot(identical(tools::md5sum(names(before)),before))
html <- xml2::xml_text(xml2::read_html(file.path(root,"define-study-area.html")))
stopifnot(!grepl("Terrain coverage review|Reach with finite data|Raster cells with finite data",html))
# Qualification only: label this separate input so synthetic assertions cannot
# be mistaken for recovered Cole Creek metadata. The cleaned report above is real.
fluvgeo::revise_study_context(context,file.path(dest,"synthetic.gpkg"),
  study_area_name="SYNTHETIC metadata qualification - NOT Cole Creek source metadata",
  add_note="Developer transport test only. Any supplied vertical reference is synthetic, not an assertion about retained terrain.")
