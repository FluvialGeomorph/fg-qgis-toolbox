# fgqgis 0.0.0.9014

- Review Saved Study Area now offers an optional read-only terrain-reference
  review, reusing fluvgeo's selected-event DEM inspector in all three views.
  Default reporting, saved records and source terrain remain unchanged.

# fgqgis 0.0.0.9013

- Retired Review Event Terrain Coverage and its percentage/chart reporting.
- Added Record Terrain Metadata: fill evidenced unknown vertical metadata for a
  selected file, preserving source data and leaving other unknowns explicit.

# fgqgis 0.0.0.9012 (withdrawn experiment)

- Added experimental Review Event Terrain Coverage, reusing saved associations
  and reporting finite, NoData/non-finite and outside-raster coverage read-only.

# fgqgis 0.0.0.9011

- Added experimental Associate Event Terrain: select an existing local GeoTIFF
  for a recorded event, with evidence/attribution and new manifest/context/report.
  No file copying, FileGDB conversion or scientific acceptance is performed.

# fgqgis 0.0.0.9010

- Added experimental Record Survey Event: enter an acquired date at its known
  precision, an explicit parent Reach, source reference and evidence note. Save
  a new context and refreshed Define Study Area report without linking assets.

# fgqgis 0.0.0.9009

- Added experimental Set Reach Areas, importing prepared GeoPackage polygons
  explicitly matched to saved Reach IDs and refreshing the Define Study Area report.

# fgqgis 0.0.0.9008

- Added experimental Add Study Reaches: enter names under one existing Stream,
  or import explicitly parented names and optional polygon areas from GeoPackage.
  Existing Reach identities are retained; no divisions or Survey Events inferred.

# fgqgis 0.0.0.9007

- Added experimental Define Initial Study Streams: names-only or explicit
  GeoPackage source mode, with a new context and updated Define Study Area report.
  Existing Stream/hierarchy identities are never replaced by this tool.

# fgqgis 0.0.0.9006

- Added experimental Set Study Area Boundary: reads one explicitly named
  GeoPackage polygon feature, delegates revision to fluvgeo, and saves a new
  context and mapped Define Study Area report. Requires a source/rationale note;
  no automatic dissolve, repair, reprojection or hierarchy inference.

# fgqgis 0.0.0.9005

- Saved Study Area review and revision now offer Terrain Development, Define
  Study Area and Staging Report views. The existing Terrain default is preserved;
  choosing a view does not change the saved study or establish acceptance.

# fgqgis 0.0.0.9004

- Added experimental Start Study Area: a thin fluvgeo adapter creating a named
  draft context and Define Study Area report without requiring acquired data.
  This new wrapper still requires actual-provider qualification; existing
  analyst profiles and production libraries are unchanged.

# fgqgis 0.0.0.9003

- Added experimental Revise Study Area Details: a thin adapter for an existing
  Study Area display name and appended analyst note, saving a new same-folder
  context copy and report through fluvgeo. Blank fields keep current values.
  This introduces free-text transport and requires the separately qualified
  development provider text correction; it is not a production deployment.

# fgqgis 0.0.0.9002

- Added experimental Review Saved Study Area, a thin read-only wrapper around
  fluvgeo's context reopening and existing Terrain Development report. The
  network-only tool remains available. No profile installation or deployment.
