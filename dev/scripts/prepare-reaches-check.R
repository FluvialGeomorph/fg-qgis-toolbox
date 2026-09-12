# Reuse isolated installation and Papillion boundary preparation. New output root.
source("dev/scripts/prepare-streams-check.R")
fluvgeo::define_study_streams(file.path(inputs,"draft.gpkg"),file.path(inputs,"streams.gpkg"),
  hucs,name_column="Name",add_note="User-confirmed HUC naming/area convention.")
# Explicit interpretation already recorded in cole-creek-terrain-report.R;
# do not teach the tool to infer parentage from overlap or filenames.
stopifnot("Little Papillion Creek" %in% hucs$Name)
gdb2006 <- system.file("extdata/y2006_R1.gdb",package="fluvgeodata",mustWork=TRUE)
hashes <- tools::md5sum(list.files(gdb2006,recursive=TRUE,full.names=TRUE))
flow <- sf::st_read(gdb2006,layer="flowline",quiet=TRUE)
stopifnot(all(flow$ReachName=="Cole Creek R1"))
sf::st_write(data.frame(Name="Cole Creek R1",Stream="Little Papillion Creek"),
  file.path(inputs,"reach inventory.gpkg"),layer="selected_reaches",quiet=TRUE)
stopifnot(identical(tools::md5sum(names(hashes)),hashes))
