# Explicit legacy candidate, not a historical polygon or universal delineation rule.
source("dev/scripts/prepare-reaches-check.R")
rows <- sf::st_read(file.path(inputs,"reach inventory.gpkg"),layer="selected_reaches",quiet=TRUE)
ctx <- fluvgeo::add_study_reaches(file.path(inputs,"streams.gpkg"),file.path(inputs,"reaches.gpkg"),
  rows,name_column="Name",parent_column="Stream",parent_key="stream_name",
  add_note="Retained Cole Creek R1, explicitly assigned to Little Papillion Creek.")$context
gdb <- system.file("extdata/y2016_R1.gdb",package="fluvgeodata",mustWork=TRUE)
hashes <- tools::md5sum(list.files(gdb,recursive=TRUE,full.names=TRUE))
dem <- terra::rast(gdb,subds="dem_2016_hydro_50")
e <- unname(as.vector(terra::ext(dem)))
g <- sf::st_as_sfc(sf::st_bbox(c(xmin=e[1],ymin=e[3],xmax=e[2],ymax=e[4]),crs=sf::st_crs(terra::crs(dem))))
areas <- sf::st_sf(reach_id=fluvgeo::read_study_context(ctx)$reaches$reach_id,geometry=g)
sf::st_write(areas,file.path(inputs,"reach areas.gpkg"),layer="chosen_extent",quiet=TRUE)
areas$reach_id <- "unknown-reach"
sf::st_write(areas,file.path(inputs,"reach areas.gpkg"),layer="unknown_id",quiet=TRUE)
jsonlite::write_json(list(source="fluvgeodata/inst/extdata/y2016_R1.gdb",
  subdataset="dem_2016_hydro_50",extent=e,crs_wkt=terra::crs(dem),
  method="rectangular grid extent; no cell-value mask, reprojection or buffer",
  status="legacy candidate for review; not an original or accepted multi-period boundary"),
  file.path(inputs,"reach-area-source.json"),auto_unbox=TRUE,pretty=TRUE,digits=NA)
stopifnot(identical(tools::md5sum(names(hashes)),hashes))
