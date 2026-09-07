##fg_check_flowline_fixture=name
##Check flowline (test fixture only)=display_name
##FluvialGeomorph=group
##Layer=vector
##Result=output string

#' ALG_DESC: Test-only adapter for fluvgeo flowline validation. Not a released tool.
#' ALG_VERSION: 0.0.0.9000
#' Layer: One retained flowline with its original ReachName and CRS. Not modified.
#' Result: The string valid on success. Backend validation failures propagate.

if (fluvgeo::check_flowline(Layer, step = "create_flowline")) {
  Result <- "valid"
}
