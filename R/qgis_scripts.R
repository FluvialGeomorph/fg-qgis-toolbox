#' Locate packaged QGIS Processing R scripts
#'
#' Returns paths only. Does not configure QGIS, copy scripts, install packages,
#' or execute an algorithm. The foundation release contains no deployable tools.
#'
#' @return Character vector of absolute paths to packaged `.rsx` files.
#' @export
#' @examples
#' qgis_scripts()
qgis_scripts <- function() {
  directory <- system.file("rscripts", package = "fgqgis", mustWork = TRUE)
  sort(list.files(directory, pattern = "\\.rsx$", full.names = TRUE))
}
