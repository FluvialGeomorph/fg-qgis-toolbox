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
| The real parameter dialog renders and preserves its input/output values offscreen; the subsequent analyst run generated the report. | The returned trial exposed delayed cancellation and conflicting failure/output messages; see the review below. |

These results concern **execution interoperability**. The earlier
[raster storage experiment](../../../FGDB/dev/experiments/geopackage-raster/FINAL-FINDINGS.md)
asked a different question and supports the accepted GeoPackage-vector/GeoTIFF-terrain
folder design. This test neither reopens that decision nor establishes general
geometry, raster or CRS round-trip equivalence.

**Next action:** review the provider-maintenance/upstream path before production
adoption. The isolated candidate now has both regression evidence and a successful
[desktop cancellation confirmation](#desktop-cancellation-confirmation-2026-09-09);
it is not a production plugin update.
See the [project plan](../goals/project-plan.md). Technical details follow for developers;
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
  2026-09-09. Subsequent analyst execution is recorded in the return review below;
  broader usability and cancellation qualification remain open.

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

## Analyst trial return: 2026-09-09

**Outcome:** desktop access to the R report works. Cancellation does not yet meet
the expected interaction contract; this is developer work, not analyst error.

The analyst returned `analyst_report.html`, `analyst_report2.html`, `log-1.txt`
and `log-2.txt` under `dev/check-output/desktop-trial-v1/Cole Créek inputs/`.
The saved text logs use Windows-1252; decoding them as UTF-8 can display replacement
characters and is not evidence that the input path was corrupted.

| Evidence | Finding |
| --- | --- |
| Verified first execution log | QGIS 3.44.14 / R Provider 4.1.0 invoked the configured test library and R guard; the run completed in 11.28 seconds. |
| Verified returned HTML | Both reports have nine tables agreeing with the retained direct-R baseline except the validation timestamp, and both have closing HTML markup. These checks do not constitute a separate visual comparison of every figure. |
| Verified source integrity | The trial input and original source still match the recorded SHA-256 `5200dd479aee0bf85c8a5430c9cfb556f6aa920c2a4611c5248f6aa26751df6f`. Launch dependency checks still pass. |
| Analyst observation | The analyst completed the short test and explicitly confirmed pressing Cancel on the second run, with a delay. |
| Verified second execution log | It reports failure after 11.18 seconds, then says HTML was generated. The second report exists and its checked contents are complete; it is not an accepted successful run merely because the file exists. |

**Verified source behavior:** the installed provider's `processing/utils.py`
`execute_r_algorithm()` waits for `proc.stdout.readline()` and checks
`feedback.isCanceled()` only after receiving a line. It calls `terminate()` on
the immediate R process, not an explicit process-tree cleanup operation.
The backend publishes the staged HTML before the provider returns output values.
QGIS's `AlgorithmDialog.finish()` adds returned HTML to its results list even
when the completion status is unsuccessful. This explains the conflicting
failure/HTML messages without reclassifying the failed run as successful.

**Inference:** quiet R rendering delayed cancellation handling, allowing report
publication before the run finished with a canceled/unsuccessful status. The
source supports that mechanism, but the saved logs contain no cancellation-click
timestamp, so the exact delay and ordering cannot be reconstructed.

**Cleanup limits:** a later process snapshot found no Rscript or Pandoc process;
an Rterm session predated the trial and was left untouched. That is not evidence
of prompt child cleanup at the time of cancellation. Process-parent inspection
was unavailable on this host. No staging files remained beside the submitted
reports; temporary-directory cleanup at cancellation was not observed.

The original reports/logs were preserved. Read-only table comparison evidence is
under ignored `dev/check-output/desktop-trial-review-v1/`. This review does not
patch the installed provider, change scientific methods, or approve deployment.

## Cancellation candidate: 2026-09-09

**Implemented, development only:** `4.1.0-fg-cancel1` adapts a checksum-pinned
copy of North Road 4.1.0. It polls process state independently of console output,
stops only the owned Windows R process tree on cancellation, checks cancellation
before output handoff, and reports nonzero R exit status without the secondary
missing-output-file traceback. Science and the `.rsx` tool are unchanged.
The [candidate notes and reproducible staging](../patches/r-provider-cancellation/README.md)
record its source, licensing, safety limits and non-deployment status.

**Verified:** the original provider took 3.765 seconds to return after cancellation
during a four-second quiet fixture and still returned success plus an HTML path.
In the final candidate run, quiet cancellation returned in 0.188 seconds;
post-publication cancellation in 0.172 seconds; child-process cancellation in
0.141 seconds. These are local measurements, not general timing guarantees.
All canceled cases returned an unsuccessful status and an empty result mapping.
Already-written files were retained with an explicit unaccepted-output warning.

Eight cases pass: quiet cancellation, normal completion, nonzero exit,
pre-canceled start, cancellation after publication, cancellation at output parsing,
large console output, and cancellation with a real child R process. An open
Windows process handle verified that the known child exited, rather than merely
disappearing from a process-name listing. The output-parsing timing case uses a
scoped test hook because QGIS clones algorithms; it is not a recorded human click.

Evidence: `dev/check-output/cancel-baseline-v1/` and
`dev/check-output/cancel-candidate-v1/tests-complete/`. The earlier sandbox-denied
cleanup attempt is not a pass; the permitted run exercised actual termination
of only test-created processes. An intermediate timing-test hook failed to reach
the cloned algorithm; the corrected class-scoped hook is restored after its case.

The same candidate also passes real Cole Creek report generation, source hashes,
overwrite/missing-input failures and agreement of all nine direct-R tables except
the validation timestamp (`dev/check-output/desktop-trial-cancel-v1/`). The latter
contains a separate prepared profile with the visibly identified candidate.
The original analyst profile, upstream source and submitted evidence are unchanged.

**Still unqualified:** detached/reparented children, cancellation after provider-to-QGIS handoff, complete
temporary-file cleanup, other operating systems and production distribution.
Forcefully stopped R cannot be assumed to run cleanup hooks. No source/output
deletion or transaction rollback is implemented; retained canceled files are not
automatically accepted. Upstream contribution or a maintained production adaptation
requires separate review; nothing has been submitted or deployed automatically.

## Desktop cancellation confirmation: 2026-09-09

**Verified:** the returned `desktop-trial-cancel-v1/Cole Créek inputs/log-1.txt`
identifies **4.1.0-fg-cancel1**, records the explicit cancellation message and no
successful HTML result. The requested `analysis_report.html` is absent; the
source/dependency hash preflight still passes. The run began at 15:06:00 local
time and ended after 1.44 seconds total. That total is not a measurement of
button-click-to-stop latency; the log does not timestamp the click.

**Analyst observation:** after closing QGIS and launching the candidate profile,
the analyst reported that Cancel was immediate. This completes the bounded
desktop confirmation for this tool/runtime, alongside the earlier controlled
timing and child-cleanup tests. No repeat of this analyst exercise is requested.

The preceding `log-3.txt` and `log-4.txt` in the original trial directory identify
official **4.1.0**, so their delayed results are baseline observations, not
candidate failures. Selecting another data folder does not change the provider
loaded in an already-running QGIS session. The guide now makes that distinction
explicit. Original evidence and profiles are preserved.

## Remaining qualification

The [isolated analyst trial](../workflows/qgis-desktop-trial.md) is prepared.
On 2026-09-09, its copied provider and desktop-compatible settings passed the
actual success/failure cases, source preservation and direct-R table comparison
again (`dev/check-output/desktop-trial-v1/`). Launch preflight passes. This is
preparation evidence; the subsequent desktop results are recorded above.

**Still unknown/unqualified:** broader interactive usability, cancellation/child
cleanup beyond the tested cases, temporary-output lifecycle,
missing installed dependencies/Pandoc in the provider, broader CRS/grid fidelity,
QGIS 4 compatibility and release-version dependency bounds. Follow the remaining
[boundary checklist](../architecture/qgis-r-boundary.md); do not promote this
experiment into a production installation procedure.
