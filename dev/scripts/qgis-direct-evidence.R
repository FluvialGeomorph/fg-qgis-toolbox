# Run with the same R environment as the provider, using installed packages.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 3L)
.libPaths(c(args[1], .libPaths()))
warnings_seen <- character()
result <- withCallingHandlers(fgqgis::with_qgis_spatial_environment({
  review <- fluvgeo::terrain_development_summary(network = args[2])
  output <- fluvgeo::terrain_development_report(review, file.path(args[3], "direct-report.html"))
  list(r = R.version.string, fluvgeo = as.character(utils::packageVersion("fluvgeo")),
    fluvgeo_path = find.package("fluvgeo"), sf = as.character(utils::packageVersion("sf")),
    terra = as.character(utils::packageVersion("terra")), spatial = as.list(sf::sf_extSoftVersion()),
    locale = Sys.getlocale(), segment_count = nrow(review$segments),
    validation_result = review$validation$stream_network_validation_run$result,
    gaps = review$gaps)
}), warning = function(w) {
  warnings_seen <<- c(warnings_seen, conditionMessage(w))
  invokeRestart("muffleWarning")
})
result$warnings <- unique(warnings_seen)
provider <- xml2::read_html(file.path(args[3], "network review.html"))
direct <- xml2::read_html(file.path(args[3], "direct-report.html"))
tables <- function(doc) vapply(xml2::xml_find_all(doc, "//table"),
  function(x) gsub("[[:space:]]+", " ", xml2::xml_text(x)), character(1))
pt <- tables(provider); dt <- tables(direct)
stopifnot(length(pt) == length(dt))
result$table_count <- c(provider = length(pt), direct = length(dt))
result$identical_tables <- which(pt == dt)
result$different_tables <- which(pt != dt)
result$different_table_text <- lapply(result$different_tables,
  function(i) list(table = i, provider = pt[i], direct = dt[i]))
stable <- function(x) {
  generated <- grepl("^ validation_level result validated_at ", x)
  x[generated] <- sub("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}",
                      "<generated timestamp>", x[generated])
  x
}
result$tables_match_except_validation_timestamp <- identical(stable(pt), stable(dt))
jsonlite::write_json(result, file.path(args[3], "direct-evidence.json"),
                     pretty = TRUE, auto_unbox = TRUE)
print(result)
stopifnot(result$tables_match_except_validation_timestamp)
