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
