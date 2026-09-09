# First actual QGIS R Provider qualification

Date: 2026-09-08. Status: headless integration exercised; **not deployed or
fully desktop-qualified**. This supplements the direct-R wrapper tests.

Update 2026-09-09: the local PROJ data repair is complete and verified; the
provider and direct-R comparison pass afterwards. A real Qt parameter dialog
was inspected offscreen. See the [repair and verification record](../workflows/osgeo-proj-repair.md).
The environment-failure discussion below is retained as dated investigation evidence.

## Runtime and isolation

The user-supplied `Local/QGIS` directory contains QGIS4 cache data. Shortcut and
32-bit uninstall-registry inspection located the actual OSGeo4W installation at
`C:/Users/R1Suser/AppData/Local/Programs/OSGeo4W`. The imported runtime reports
QGIS **3.44.14-Solothurn**. QGIS 4.2.2 also has an installed desktop shortcut;
this test does not qualify its runtime. The official
[R Provider 4.1.0 listing](https://plugins.qgis.org/plugins/processing_r/version/4.1.0/)
declares QGIS 3.4–3.99 compatibility, so the installed 3.x build was selected.

The official plugin archive was staged under ignored `dev/check-output/`, not
installed into the user's profile. SHA-256:
`058140685bbc498c85dc3f7802a5e6712ea92d549dd084b54751f39c7a1f4d17`.
Its source was not patched. fluvgeo 2026.9.4.9000 was installed from sibling
source `12d3c9b` into a test-local R library; dependencies remain the existing
R installation's packages. Runtime: R 4.6.0, sf 1.1.2, terra 1.9.46;
sf reports GDAL 3.12.1, GEOS 3.14.1 and PROJ 9.7.1.

The harness uses QGIS's real Processing registry, provider parser and R
subprocess. Only the R provider is registered, not all unrelated Processing
providers. Its scripts folder is `inst/rscripts`, never the repository root.
Qt runs offscreen. `QGIS_CUSTOM_CONFIG_PATH` and isolated INI settings keep
profile writes inside the run directory; the harness asserts the resolved
profile location. R user startup files are disabled with test-local nonexistent
paths. No shared QGIS/R installation, normal profile, ArcGIS tool or Shiny app
was modified. Early harness discovery failures are not wrapper test failures.

## Verified behavior

- The real provider parses the wrapper and its inline help, exposing exactly
  INPUT and OUTPUT. Its actual ID is **`r:fgreviewstreamnetwork`**: the provider
  strips underscores from the declared `fg_review_stream_network` name.
- The existing Cole Creek draft bundle can be reviewed from a copied path with
  spaces and accented text. QGIS returns the new HTML output path and success.
- An existing report is refused and its SHA-256 remains unchanged. A missing
  network input fails and creates no report. Source and copied network hashes
  remain unchanged. These are actual provider executions, not mocked calls.
- The provider emits the useful backend error, then an additional
  `FileNotFoundError` for its absent `processing_values.txt`. QGIS reports failure,
  not success, but the secondary traceback is confusing. Do not suppress the
  backend failure or manufacture a success result to avoid that traceback.
- Inline help was generated and saved as HTML; visual QGIS dialog/help review
  has not occurred. A successful headless run is not a GUI usability test.

## Environmental findings and limits

The paragraphs below preserve the initial experiment. The later packaged guard
is described under "Packaged runtime boundary" below; wholesale removal by the
test harness is no longer required for the tool to isolate recognized settings.

**Verified:** QGIS initialization reports that the OSGeo4W `share/proj/proj.db`
has layout minor version 2 while its loaded PROJ requires at least 4. This is
an environment consistency failure, not a demonstrated wrapper geometry bug.
Repairing the shared OSGeo4W installation is outside this test; no database was
replaced and no CRS definitions were silently substituted.

**Verified:** the inherited OSGeo4W GDAL plugin path causes R's independently
bundled GDAL to try loading incompatible OSGeo4W driver DLLs. The baseline direct
run captured 20 distinct warning texts (including repeated forms) and the
provider reported 50+ warnings. This demonstrates why a successful HTML file is
insufficient for deployment qualification.

The harness can test removal of `GDAL_DRIVER_PATH`, `GDAL_DATA`, `PROJ_LIB` and
`PROJ_DATA` after QGIS initialization, before its R subprocess starts. This is a
process-local experiment, not a shipped wrapper behavior or a general policy to
discard legitimate user-selected grids/drivers. A durable R subprocess
environment contract remains to be designed before deployment.

**Verified controlled comparison (`run-13`):** clearing those inherited spatial
overrides removed all captured R warnings, and the real provider's successful
run emitted no warnings/errors. Both reports contain nine tables: eight are
text-identical; the ninth differs only in the fresh validation timestamp.
Validation remains `REVIEW_REQUIRED`, as expected for this one-segment draft.
Overwrite and missing-input failures still behave safely, including the same
secondary provider traceback. This isolates the R driver-conflict mechanism;
it does not resolve QGIS's own PROJ database mismatch, which still appears at
QGIS initialization. No pixel/geometry round-trip equivalence is claimed from
HTML table comparisons.

## Repeatable evidence

`dev/scripts/qualify-qgis-provider.py` takes explicit OSGeo4W, plugin-parent,
R-home/library, source-network and **new** output-root paths. It downloads and
installs nothing. Invoke it through `bin/python-qgis-ltr.bat`, with Pandoc exposed
through the workstation's `RSTUDIO_PANDOC` setting. Example options:

```text
--osgeo <OSGeo4W root> --plugin-parent <directory containing processing_r>
--r-home <R installation> --r-library <test library>
--input <existing network.gpkg> --output-root <new run directory>
```

Add `--isolate-r-spatial-env` only for the controlled environment comparison.
`qgis-direct-evidence.R` runs afterwards with the same environment and installed
backend, captures warnings/versions, and compares HTML table contents with the
provider report. Fresh validation IDs/times are expected to differ.
Full outputs are ignored under `dev/check-output/qgis-provider-v1/`; retain
`run-12` as the inherited-environment baseline. The published plugin archive,
test library and raw reports are not distribution assets.

The current harness requires fgqgis installed into the supplied test R library,
loads its installed `rscripts` directory and checks that the script matches the
working source. The initial experiments above used source `.rsx` assets.

## Packaged runtime boundary

`fgqgis` 0.0.0.9001 introduces `with_qgis_spatial_environment()`, used by the
network-review wrapper before loading fluvgeo. It recognizes only paths inside
OSGEO4W_ROOT, refuses custom/mixed or already-loaded spatial-library state when
isolation is needed, reports its action and restores environment values on
success/error. See [ADR-0004](../decisions/ADR-0004-r-spatial-runtime-boundary.md).
The direct-R comparison now invokes that same environment helper; its scientific
summary/report calls remain direct fluvgeo calls.

Read-only SQLite inspection confirmed that the actual OSGeo4W `proj.db` reports
PROJ **8.2.1**, database layout **1.2**, EPSG **v10.041** dated **2021-12-03**.
The file's recorded modification date is 2022-01-04. OSGeo4W's package inventory
lists PROJ **9.8.1** and the installed QGIS runtime rejects this old database.
Thus the stale file is verified; how it survived the installation/update is
unknown. Recommended repair is through the installation's package manager,
with before/after checks, not copying R's database or editing CRS records by hand.
No shared installation repair has been performed.

Verified packaged run (`run-14`): installed fgqgis **0.0.0.9001** supplies both
the script and guard, with no `--isolate-r-spatial-env` harness flag. The wrapper
reports its own isolation; report generation, unchanged-source checks,
overwrite refusal and missing-input failure all pass. Direct-R evidence captures
zero warnings; all nine HTML tables match after allowing only the generated
validation timestamp to differ. The provider's extra failure traceback and
QGIS's initialization warning remain visible. Fast tests now include 23 guard
assertions (path recognition/refusal, preloaded namespace refusal, caller
evaluation and restoration after success/error), plus 28 script-contract
assertions; the 66 testthis integration assertions also pass. The source-loaded
integration suite explicitly removes overrides for adapter comparisons because
its already-loaded spatial packages can set their own GDAL_DATA; it does not
claim to simulate fresh-process initialization. `run-14` tests that boundary.
The 0.0.0.9001 source build and `R CMD check --no-manual --no-vignettes` completed
with **Status: OK** (`dev/check-output/guard-package-v1/`). As before, the check
used `_R_CHECK_FORCE_SUGGESTS_=false`; absent optional backend/data/testthis
packages were exercised separately by the explicit suite and provider run.
Strict context validation passed with the two existing seeded-content warnings.

The 27 fast package assertions and strict reproducibleai context validation
were rerun successfully (two existing seeded-content warnings). No packaged
wrapper/backend behavior changed in this turn; the new code is development-only
qualification tooling. The previous package build/check is not a QGIS release
qualification. Changes remain available for user review and commit.

**Still unknown/unqualified:** interactive parameter/help usability, actual
desktop profile loading, cancellation/child cleanup, temporary-output lifecycle,
missing installed dependencies/Pandoc in the provider, broader CRS/grid fidelity,
QGIS 4 compatibility and release-version dependency bounds. Follow the remaining
[boundary checklist](../architecture/qgis-r-boundary.md); do not promote this
experiment into a production installation procedure.
