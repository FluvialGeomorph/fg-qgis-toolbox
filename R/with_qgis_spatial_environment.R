#' Run a QGIS wrapper using R's own spatial-library resources
#'
#' For a fresh, dedicated R Provider subprocess. Before spatial namespaces are
#' loaded, temporarily removes GDAL_DRIVER_PATH, GDAL_DATA, PROJ_LIB and PROJ_DATA
#' overrides only when every configured path resolves inside OSGEO4W_ROOT.
#' Unrecognized/custom overrides or already-loaded spatial namespaces fail
#' visibly rather than guessing or pretending cached library state was reset.
#'
#' No overrides means no action. Empty variables are treated as absent. Names of
#' removed variables are reported, never their values. Environment values are
#' restored on normal return or error; loaded libraries are not unloaded/reset.
#' This does not repair QGIS, modify files, change CRS definitions, or qualify
#' arbitrary custom grid/driver installations. Do not use this as a switch
#' between spatial runtimes within a long-lived R session.
#'
#' @param code Expression to evaluate in the caller's environment after checks.
#' @return The value of `code`, preserving visibility.
#' @export
with_qgis_spatial_environment <- function(code) {
  keys <- c("GDAL_DRIVER_PATH", "GDAL_DATA", "PROJ_LIB", "PROJ_DATA")
  old <- Sys.getenv(keys, unset = NA_character_)
  active <- names(old)[!is.na(old) & nzchar(old)]
  if (!length(active)) return(eval(substitute(code), parent.frame()))

  root <- Sys.getenv("OSGEO4W_ROOT", unset = "")
  canonical <- function(path) {
    if (!length(path) || anyNA(path) || any(!nzchar(path)) ||
        any(!dir.exists(path))) return(NULL)
    result <- normalizePath(path, winslash = "/", mustWork = TRUE)
    if (.Platform$OS.type == "windows") result <- tolower(result)
    sub("/+$", "", result)
  }
  root <- canonical(root)
  recognized <- vapply(old[active], function(value) {
    separator <- .Platform$path.sep
    if (startsWith(value, separator) || endsWith(value, separator) ||
        grepl(paste0(separator, separator), value, fixed = TRUE)) return(FALSE)
    paths <- canonical(strsplit(value, .Platform$path.sep, fixed = TRUE)[[1]])
    !is.null(root) && !is.null(paths) &&
      all(paths == root | startsWith(paths, paste0(root, "/")))
  }, logical(1))
  if (!all(recognized)) {
    stop("Unrecognized spatial environment overrides: ",
         paste(active[!recognized], collapse = ", "),
         ". Use a fresh R Provider process with reviewed OSGeo4W settings or no overrides; custom grid/driver paths require separate qualification.",
         call. = FALSE)
  }
  if (length(.fgqgis_loaded_spatial())) {
    stop("Spatial packages are already loaded. Start a fresh R Provider process with automatic package loading disabled before isolating OSGeo4W overrides.",
         call. = FALSE)
  }
  on.exit({
    Sys.unsetenv(keys[is.na(old)])
    restore <- old[!is.na(old)]
    if (length(restore)) do.call(Sys.setenv, as.list(restore))
  }, add = TRUE)
  Sys.unsetenv(active)
  message("Using R's spatial resources; temporarily ignoring inherited OSGeo4W overrides: ",
          paste(active, collapse = ", "), ".")
  eval(substitute(code), parent.frame())
}

.fgqgis_loaded_spatial <- function() {
  intersect(c("sf", "terra", "raster", "rgdal"), loadedNamespaces())
}
