# Associate Event Terrain

## Outcome

Connect a recorded Survey Event to a selected local GeoTIFF and refresh the same
evolving Define Study Area report. This fills the gap between an acquisition's
source label and an explicitly inventoried terrain file. It does not establish
scientific suitability or convert the archive. Development versions: fgqgis
0.0.0.9011 / fluvgeo 2026.09.11.9006; qualified development provider 4.1.0-fg-text1.

The report now shows the associated file, fingerprint check, grid-preview status,
and known/unknown vertical reference and unit. Detailed evidence and integrity
findings remain collapsible. Its next decisions are to resolve integrity/metadata
issues and assess coverage and suitability, not assume comparisons are ready.

## Contract and boundaries

- Choose the exact saved Survey Event ID and an existing single-band GeoTIFF.
  Supply association evidence and attribution. New artifact IDs are local labels,
  not enterprise reconciliation; no acquisition dates or parentage are inferred.
- Place terrain in the new manifest's folder tree beforehand. The manifest must
  be inside the saved context tree and, if an inventory already exists, beside it.
  No copying, raster conversion, resampling or reprojection is performed.
- Save new manifest, same-folder context and HTML destinations. Continue the new
  context for subsequent events. Keep the complete linked folder together.
- Earlier records, geometries, event IDs, associations and file fingerprints remain
  unchanged. A shared file can be deliberately linked to another event if integrity
  checks pass; an existing event selection is refused, never silently replaced.
- Adding terrain preserves old missing/changed-file findings. The new manifest
  revision is not a refresh of every saved fingerprint. JSON nulls remain null
  across read/write; tests caught and corrected the default empty-list encoding.
- Unknown vertical metadata stays unknown, including for source names containing
  `ft`. Grid preview means metadata could be loaded, not valid-cell coverage or
  scientific comparability. Existing metadata assertions are retained.
- Outputs are not one transaction. Later failure/cancellation may leave a manifest
  and context. Inspect retained outputs and use read-only reporting if the context
  exists. No automatic destructive cleanup or concurrent asset mutation is supported.

The shared API and existing schema bindings are additive. fluvgeo owns the logic;
the `.rsx` is a thin adapter. ArcGIS toolbox, ohwm2, RegionalCurve, production
libraries/profiles and release workflows are unchanged. fluvgeodata remains
read-only evidence. Complete folder delivery/FGDB loading, generic migration,
selection replacement and vertical-metadata editing are separate work.

## Cole Creek qualification

`prepare-event-terrain-check.R` takes a new output root and the preceding saved
three-event context. It preserves those IDs, installs only an isolated test
library, and exports the explicitly selected retained terrains:
`dem_2006_ft_50`, `dem_2010_ft_50`, `dem_2016_hydro_50`. The developer fixture checks
exact values/NoData, grid and semantic CRS against FileGDB sources and checks
source hashes. This explicit fixture export is not functionality of the tool.
No vertical metadata is inferred; the prior 2016 Reach rectangle remains a
candidate, not a confirmed multi-period boundary.

Run focused backend/context/report tests, testthis wrappers and fast package
tests. Use `qualify-qgis-provider.py --event-terrain-context` with the prepared
`fixtures/study.gpkg`, its library and the qualified provider; use a separate
new root for `--inspect-dialog-only`. Evidence is ignored under
`dev/check-output/event-terrain-v1/`.

Three sequential actual-provider associations are compared with direct R:
normalize only each new artifact UUID, compare all prior records exactly, and
compare final report tables. Eight refusal cases cover an already selected event,
unknown event, missing/wrong-format file, missing evidence and all three output
collisions. Unit tests additionally cover shared files, relocation, changed and
missing prior files, path boundaries, unknown metadata and report-failure recovery.
Offscreen form qualification is not a new analyst usability result.

Next: [record evidenced terrain metadata](record-terrain-metadata.md), reusing
this saved association instead of asking the analyst to repeat file/event matching.
The later rectangle-coverage experiment was withdrawn: intentional NoData/AOI
masking is not missing-data or quality evidence.

### Verified developer results (2026-09-11)

- The focused backend suite covers 604 passing assertions (including a final 58-assertion
  terrain-association rerun); testthis wrappers pass 197 and fast package tests
  pass 170. No test failures, assertion warnings or skips remain. The first test
  invocation lacked the workstation UTF-8 locale and exposed an existing Unicode
  round-trip failure; the correctly configured rerun passes. Installed-package
  startup warnings for R 4.6.1-built packages on R 4.6.0 remain.
- Actual QGIS 3.44.14 / R Provider 4.1.0-fg-text1 registers
  `r:fgassociateeventterrain`. All eleven execution/refusal cases pass. Direct-R
  comparison confirms unchanged hierarchy/event identities and prior artifact
  records, equivalent new associations, identical final report tables, three
  loaded grids and three unresolved vertical-metadata findings. Source/copy hashes
  remain unchanged. Evidence is in `provider/`.
- Developer exports of all three selected Cole Creek terrains preserve exact
  values/NoData, grids and semantic CRS; original FileGDB hashes are unchanged.
  These are explicit fixture-copy results, not a claim that the new tool performs
  conversion or qualifies all archive rasters.
- All eight parameters round-trip through the actual offscreen Qt form; its
  screenshot was inspected. No visible desktop session was launched, analyst
  usability trial inferred, or production profile/library upgraded.
- Native source builds/checks finish with fgqgis `Status: OK` and fluvgeo
  `Status: 2 NOTEs`: existing undeclared `methods` use and package-wide globals/
  imports. Manuals/vignettes are excluded; fluvgeo full tests/examples are excluded
  and its check lacks suggested fluvgeodata. Workspace tests above use retained
  data. Network-index and Windows `du` diagnostics remain environmental limits.
  These source checks preceded the final one-line partial-context compatibility
  adjustment: use the already recorded Stream parent ID for the local intake label
  when the descriptive Study Area record is absent. Final focused tests cover that
  case without inventing the missing record; the final installed library is also
  compared again with the saved actual-QGIS results (`direct-evidence-final.json`).
- Strict reproducibleai validation passes in both repositories with only the five
  existing seeded-content customization notices. Preserve those customizations.
  Changes are uncommitted alongside preceding increments; archive sources and
  production clients remain untouched.
