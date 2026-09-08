# Packaged Processing scripts

Experimental algorithms belong here as `.rsx` files with inline help.
`fg_review_stream_network.rsx` has direct-R tests but is not QGIS-qualified.
Its presence in a package does not authorize deployment.
`fgqgis::qgis_scripts()` discovers scripts without configuring QGIS.

Do not configure the provider to scan the repository root: it scans recursively
and would discover test fixtures. A later reviewed deployment will expose only
the installed package's `rscripts` directory or an explicitly staged copy.
