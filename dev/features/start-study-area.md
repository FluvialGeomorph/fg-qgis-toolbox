# Start Study Area

## Outcome and boundary

First prospective entry, 2026-09-10: begin a genuinely new study before acquired
data exist. **Start Study Area (experimental)** asks for a working name, optional
purpose/scope notes and two new output paths. The thin wrapper delegates to
`fluvgeo::start_study_context()` and returns the saved context plus an offline
**Define Study Area** report. No archive, FileGDB, DEM or completed survey is a
prerequisite. This follows the shared [reporting intent](../../../fluvgeo/dev/goals/reporting-intent.md).

The backend generates one local Study Area UUID, retaining it through existing
name/note revisions. It does not discover a historical identity, register an
enterprise record or infer a boundary, CRS, Stream, Reach or acquisition date.
The shared [context schema](../../../fluvgeo/dev/schemas/study-context.md) is
unchanged. Notes remain free text; structured requirements, alternatives and
planned observations need further design. Starting again creates another ID:
reopen/revise an existing study instead.

The report distinguishes supplied scope from open design conversations. It does
not show the legacy-staging or terrain-quality action queue for a new empty draft.
It does not assert readiness. Existing Terrain/Staging reports and saved-context
APIs retain their behavior. The frozen analyst review/editor forms render their
combined Terrain Development report. The next development version adds explicit
[report-view selection](review-study-area.md#report-view-selection-2026-09-11)
without upgrading those earlier profiles in place.
An R caller can regenerate this view with `define_study_area_report()` from the
reopened summary without creating another context or changing data.

## Wrapper contract

Packaged script: `fg_start_study_area.rsx`; name declaration `fg_start_study_area`.
Parameters: required `STUDY_NAME`, optional multiline `SCOPE_NOTES`, output
`CONTEXT` (.gpkg) and `OUTPUT` (.html). Blank notes map to typed missing text.
Outer whitespace is trimmed by the backend; interior text is preserved.
The verified provider registry ID is `r:fgstartstudyarea`; the offscreen form
preserves all four parameters. Analyst usability remains to be confirmed.

Existing destinations are refused before saving. Output directories must exist
and support hard links. A report failure after saving can leave the context;
retain it and retry read-only reporting, not study creation. No source assets are
copied, production libraries updated or profiles configured by the wrapper.

## Verification and next boundary

Backend tests cover name-only/notes drafts, generated identities, continuation
without identity changes, absent acquired data, invalid input, non-overwrite,
partial-output recovery, report escaping and read-only re-rendering. The testthis
suite compares the actual wrapper body to direct R, allowing independently
generated UUIDs to differ, and preserves retained fluvgeodata archive hashes.
Source-level tests are not proof of QGIS parser/transport or analyst usability.

The earlier editor trial is closed: the user found its form crystal clear and
familiar from ArcGIS Pro. That evidence is encouraging for the starter, not a
substitute for its own qualification. Actual-provider qualification is now
complete below; the [one-start analyst trial](../workflows/qgis-desktop-trial.md)
is prepared in a new isolated library/profile. Existing trial profiles and
production clients remain untouched.

### Verified source checks (2026-09-10)

- R 4.6.0; fgqgis 0.0.0.9004 and sibling fluvgeo 2026.09.10.9001.
- 333 focused backend assertions, 90 fast package assertions and 100 explicit
  testthis wrapper assertions passed with no test failures or skips. The backend
  set includes existing context, Terrain reporting, manifests and event links.
- The synthetic prospective example and package-check evidence are under ignored
  `dev/check-output/study-start-v2/`. The example states that it is illustrative,
  not a customer-approved scope. HTML content/escaping and read-only rendering
  were tested; automated browser visual inspection was unavailable for the local
  file URL. No claim of analyst review of this new report is made.
- Both repositories pass strict reproducibleai validation with their existing
  modified-seed notices. Generated help and Git whitespace checks pass.
- fgqgis source-package check reports `Status: OK`. Its missing optional installed
  backend/data/testthis packages were exercised separately through the explicit
  workspace suite. Native R commands avoid an unnecessary compiler prerequisite
  from the convenience checker. No compiler installation was required.
- fluvgeo's scoped source-package check reports zero errors/warnings and the same
  two existing notes (undeclared methods use and package-wide globals/imports).
  Tests/examples were excluded from that check; focused tests ran separately.
  The full external-service suite and actual QGIS provider were not run.
  R 4.6.0 startup notes dependencies built under 4.6.1; offline repository-index
  and workstation `du` diagnostics did not change the final check status.

Scoped searches found no existing callers of the new APIs in the production
ArcGIS toolbox, ohwm2, RegionalCurve or FGDB R/Python code. Those repositories and
fluvgeodata are unchanged. New functions are additive; no scientific algorithm,
CRS contract, acquisition rule or accepted identifier is changed.

### Actual-provider qualification (2026-09-11)

**Verified:** QGIS 3.44.14-Solothurn / R Provider 4.1.0-fg-text1 registers
`r:fgstartstudyarea` with inline help, required name, optional multiline notes
and two declared outputs. A newly installed isolated library contains fgqgis
0.0.0.9004 and fluvgeo 2026.09.10.9001, using R 4.6.0. No package/wrapper/backend
code was changed for this qualification; only developer harnesses and records.

Six actual-provider cases passed: Unicode/name/notes success, overwrite refusal,
blank-name refusal, existing-report refusal, provider-created output directory,
and blank-notes success. Rejected runs returned no successful outputs and did not
replace existing files. The three successful starts created distinct local IDs;
none inferred acquired data. Text (quotes, backslashes, Unicode, multiline notes)
is exact. The visible report body matches a fresh direct-R rendering from the
same saved context except snapshot time. Comparison does not alter the contexts.

The first run exposed an incorrect test expectation, not a backend defect:
provider `algorithm.py` creates file-output parents before invoking R. The R API
therefore sees an existing directory. Raw evidence is retained in
`dev/check-output/study-start-qgis-v1/desktop-trial/`, without a launch manifest.
The corrected final run is `desktop-qualified/`; its `trial.json` is published
only after success/refusal checks and direct comparison. QGIS-created directories
are not the standardized FluvialGeomorph hierarchy; invalid runs may leave empty
directories. For the trial, choose the supplied existing output folder.

The offscreen Qt form in `dialog/` round-trips all four parameters; its screenshot
was visually inspected. The schema-4 launcher passed valid preflight and twelve
in-memory refusal checks. Existing schema-3 and schema-2 trials retain their
twelve and six passing refusal checks. No saved manifests were altered by tests.
Strict reproducibleai context validation and Git whitespace checks passed.
Package checks were not repeated because this step changes only developer
harnesses, cache-ignore rules and documentation, not the qualified package code.

**Next / unknown:** analyst comfort with this new starter and report. No visible
QGIS desktop was launched. The trial uses developer packages, not a supported
release or a complete dependency lock. This does not qualify whole-project
configuration, conversion, enterprise loading or report-purpose selection in the
existing editor. No repeat cancellation test is required.

### Analyst return (2026-09-11)

**Technically verified:** the returned Processing log records provider
4.1.0-fg-text1, the qualified `study-start-qgis-v1/r-library`, and successful
execution in 9.73 seconds. The user saved `analyst draft.gpkg`, `analyst report.html`
and `analyst-start-log.txt` under `desktop-trial/New Créek drafts/`, rather than
the suggested `desktop-qualified/` destinations. These are valid alternate
outputs; folder choice alone does not identify the running provider. No repeat
creation is required.

The reopened name is exactly `New study — desktop trial`; blank notes remain
typed missing text. No acquired-data records were created. The visible report
body matches direct R except snapshot time. Returned context/report/log hashes
are unchanged by review. Evidence and a read-only comparison are retained in
`study-start-qgis-v1/analyst-return/`; the creation operation was not rerun.

**User direction:** the user has not reviewed the report and explicitly defers
report feedback to the next round while functionality advances. Technical review
is complete; report usability is not claimed. Do not block development or assign
another starter run merely to obtain that deferred feedback.
