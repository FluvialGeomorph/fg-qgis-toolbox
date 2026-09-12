# Preserve the previous hierarchy/area example; acquisition years are explicit
# user-confirmed fixture facts, not parsed from filenames by the new tool.
source("dev/scripts/prepare-reach-areas-check.R")
areas <- sf::st_read(file.path(inputs,"reach areas.gpkg"),layer="chosen_extent",quiet=TRUE)
current <- fluvgeo::set_study_reach_areas(ctx,file.path(inputs,"study.gpkg"),areas,
  add_note="Legacy candidate: 2016 dem_2016_hydro_50 rectangular extent; not confirmed across periods.")$context
years <- c(2006L,2010L,2016L)
for (year in years) {
  path <- system.file(paste0("extdata/y",year,"_R1.gdb"),package="fluvgeodata",mustWork=TRUE)
  hashes <- tools::md5sum(list.files(path,recursive=TRUE,full.names=TRUE))
  flow <- sf::st_read(path,layer="flowline",quiet=TRUE)
  stopifnot(all(flow$ReachName=="Cole Creek R1"),identical(tools::md5sum(names(hashes)),hashes))
}
jsonlite::write_json(list(reach_id=fluvgeo::read_study_context(current)$reaches$reach_id,
  years=years,evidence="Previously user-confirmed Cole Creek R1 survey years; retained source label. Month/day unknown. Terrain assets not linked by this entry."),
  file.path(inputs,"survey-fixture.json"),auto_unbox=TRUE,pretty=TRUE)
