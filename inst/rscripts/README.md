# Packaged Processing scripts

Future user-facing algorithms belong here as `.rsx` files with inline help.
There are deliberately no deployed algorithms in the foundation release.
`fgqgis::qgis_scripts()` discovers scripts without configuring QGIS.

Do not configure the provider to scan the repository root: it scans recursively
and would discover test fixtures. A later reviewed deployment will expose only
the installed package's `rscripts` directory or an explicitly staged copy.
