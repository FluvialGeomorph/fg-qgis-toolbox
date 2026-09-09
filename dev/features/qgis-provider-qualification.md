# First actual QGIS R Provider qualification

Reviewed: 2026-09-09. Status: one actual provider/backend path verified;
**not deployed or fully desktop-qualified**.

## Project question and conclusion

Can QGIS provide the desktop interface to fluvgeo's R science without a second
scientific implementation? **This first read-only reporting tool demonstrates
that connection.** QGIS passes a network GeoPackage path to the R backend and
receives a new HTML report. Its nine tables agree with direct R, apart from the
fresh validation timestamp, and the source remains unchanged.

This enables the planned desktop workflow; it is not a complete Study Area tool.
The network file alone does not contain the full parent/event/terrain context.
Report generation does not imply scientific acceptance or FGDB load readiness.

## What the test revealed

| Finding | Resolution or implication |
| --- | --- |
| QGIS could invoke the packaged R wrapper and return a report. | The thin-wrapper approach works for this input/tool/runtime combination. |
| QGIS's inherited spatial settings conflicted with R's own libraries. | The packaged R guard isolates only recognized settings before backend loading; unfamiliar configurations are refused. |
| Legacy OSGeo4W packages had overwritten newer coordinate-system resources. | Six package-owned files were restored from the verified archive, with backups. This was a separate installation repair, not a change to the science or GeoPackage format. |
| Missing inputs and overwrites fail without changing sources or existing reports. | Safety checks work; the upstream provider's extra error traceback remains a usability issue. |
| The real parameter dialog renders and preserves its input/output values offscreen. | Actual analyst interaction, report opening and cancellation still need a desktop trial. |

These results concern **execution interoperability**. The earlier
[raster storage experiment](../../../FGDB/dev/experiments/geopackage-raster/FINAL-FINDINGS.md)
asked a different question and supports the accepted GeoPackage-vector/GeoTIFF-terrain
folder design. This test neither reopens that decision nor establishes general
geometry, raster or CRS round-trip equivalence.

**Next action:** complete the isolated analyst trial in the
[project plan](../goals/project-plan.md). Technical details follow for developers;
the [repair record](../workflows/osgeo-proj-repair.md) owns package hashes,
backups, cause and recovery limits.

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
paths. The harness does not modify shared installations, normal profiles,
ArcGIS tools or Shiny apps. The separately authorized 2026-09-09 repair did
change six shared OSGeo4W data files, as recorded above. Early harness discovery
failures are not wrapper test failures.

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
- Inline help and the real Qt parameter dialog were inspected offscreen on
  2026-09-09. An analyst's interactive usability test remains outstanding.

## Historical diagnostic evidence: 2026-09-08

The observations below explain how the failures were isolated. Both the packaged
guard and subsequent local repair are now complete; these are not current blockers.

**Verified at baseline:** QGIS initialization reported that the OSGeo4W `share/proj/proj.db`
had layout minor version 2 while its loaded PROJ required at least 4. This was
an environment consistency failure, not a demonstrated wrapper geometry bug.
The initial experiment did not modify that database. The separately authorized
repair and post-repair checks are recorded in the maintenance record.

**Verified:** the inherited OSGeo4W GDAL plugin path causes R's independently
bundled GDAL to try loading incompatible OSGeo4W driver DLLs. The baseline direct
run captured 20 distinct warning texts (including repeated forms) and the
provider reported 50+ warnings. This demonstrates why a successful HTML file is
insufficient for deployment qualification.

The harness can test removal of `GDAL_DRIVER_PATH`, `GDAL_DATA`, `PROJ_LIB` and
`PROJ_DATA` after QGIS initialization, before its R subprocess starts. This is a
process-local experiment, not a shipped wrapper behavior or a general policy to
discard legitimate user-selected grids/drivers. The resulting packaged boundary
is described below; the comparison flag is no longer needed for normal execution.

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

Verified packaged run before the repair (`run-14`, 2026-09-08): installed fgqgis **0.0.0.9001** supplies both
the script and guard, with no `--isolate-r-spatial-env` harness flag. The wrapper
reports its own isolation; report generation, unchanged-source checks,
overwrite refusal and missing-input failure all pass. Direct-R evidence captures
zero warnings; all nine HTML tables match after allowing only the generated
validation timestamp to differ. The provider's extra failure traceback and
QGIS's initialization warning remained visible in that run. Fast tests include 23 guard
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

After the 2026-09-09 repair, provider execution and direct-R comparison passed
again, without the QGIS PROJ initialization warning. The preflight rejected a
disposable copy of the original mismatched database before QGIS initialization.
The 51 fast assertions and strict context validation also passed; details and
remaining limits are in the maintenance record. These checks are not a QGIS release.

## Remaining qualification

**Still unknown/unqualified:** interactive parameter/help usability, actual
desktop profile loading, cancellation/child cleanup, temporary-output lifecycle,
missing installed dependencies/Pandoc in the provider, broader CRS/grid fidelity,
QGIS 4 compatibility and release-version dependency bounds. Follow the remaining
[boundary checklist](../architecture/qgis-r-boundary.md); do not promote this
experiment into a production installation procedure.
