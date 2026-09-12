# Review Saved Study Area

## Optional terrain-reference review (2026-09-12)

Development fgqgis 0.0.0.9014 adds **TERRAIN REFERENCES**, an unchecked checkbox,
to this existing read-only tool. Select it to include fresh file declarations for
explicitly selected event DEMs in any of the three report views. The shared
[fluvgeo contract](../../../fluvgeo/dev/schemas/terrain-reference-review.md#saved-study-area-integration-development-9012)
owns selection, hash validation, inspection, blocked findings and reporting.
The compact gt tables are reused without separate preview pages.

Recorded manifest assertions, file declarations and unknown analysis choices
stay separate. No metadata, elevations, event links or source lineage is changed
or inferred. An empty new-study draft still renders; a missing/changed selected
DEM remains blocked, not replaced by a filename search or declared missing CRS.
Reviewing a report is not accepting metadata or completing scientific comparison.
This option does not expose analysis-choice editing or catalog discovery.

Omitted/FALSE keeps the existing backend call. TRUE requires the backend's
`terrain_references` argument; an old backend receives an explicit compatibility
error, not a silent omission. Current HTML rendering also needs gt and Pandoc.
Only the reviewer changes, not revision tools, installed analyst profiles or
production libraries. Test in a new isolated library/profile using the existing
`qualify-qgis-provider.py --study-context --terrain-references --report-view 1`
path. Actual QGIS execution and direct-R agreement are distinct from wrapper tests.

**Verified:** QGIS 3.44.14 / provider 4.1.0-fg-text1 executed the option using
fluvgeo 2026.09.12.9013 and fgqgis 0.0.0.9014 in a new isolated library. All 24
tables in the Cole Creek Define Study Area report agree with direct R apart from
fresh validation time. The three selected 2006/2010/2016 DEMs remain
`VERTICAL_CRS_NOT_EXPOSED`; no project-wide choice was inferred. Source and copied
input hashes are unchanged. Missing context and existing-output attempts fail
without publishing/replacing a report. See ignored
`dev/check-output/study-references-v1/provider-final/`.

The first run in `provider/` deliberately remains failure evidence: gt was absent
from the provider library, and no report was published. The provider replaces the
developer's appended library search path. The isolated library now contains gt
1.3.0 and eight missing runtime dependencies copied from the existing R 4.6.1
installation; remaining dependencies use registry R 4.6.0 defaults. Versions and
paths are in `runtime-packages.json`. No downloads or production-library changes
occurred. This is a qualified local development combination, not a dependency lock
or production provisioning procedure.

The fast suite passed 185 assertions and the explicit testthis wrapper suite
passed 227, with zero failures/warnings/skips. A subsequent focused run passed 51
assertions including old-backend refusal/default compatibility; its existing
fixture initialization emitted one GDAL_DATA lookup warning. The fresh actual
provider/direct-R run emitted no R warnings. No new analyst usability claim,
terrain acceptance or production deployment follows from these checks.

The default-off actual QGIS run also passed in `provider-default/`, agreeing
with direct R across 12 ordinary report tables, with preserved inputs and no R
warnings. The built fgqgis source-package check (`--no-manual --no-vignettes`)
completed with **Status: OK**, including its normal tests/examples. The testthis
suite ran separately with workspace fluvgeodata; those optional packages were
unavailable to the native check. Offline repository-index and Windows size-tool
diagnostics remain environmental limits. fluvgeo methods did not change in this
client increment, so its previously completed backend checks were not repeated.

Experimental read-only wrapper: `inst/rscripts/fg_review_study_area.rsx`.
Takes a `FLUVGEO_STUDY_CONTEXT_1` GeoPackage and a new HTML destination. It uses
the same spatial-environment guard as network review, then delegates to
`fluvgeo::read_study_context_summary()` and `terrain_development_report()`.
The existing network-only tool remains available and unchanged.

This closes the first report-reopening gap: the analyst need not rerun the demo's
R script to supply the Study Area, Streams, Reaches, Survey Events and notes.
The backend [context contract](../../../fluvgeo/dev/schemas/study-context.md)
defines portable file links and failure behavior. The wrapper does not edit that
context or create identities, repair data or approve it. Missing AOIs, unknown
vertical references and incomplete archive evidence remain explicit.

Use the **context** GeoPackage, not the network GeoPackage; retain its linked
network, intake manifest and external GeoTIFFs together. A missing/changed linked
network or manifest fails explicitly. Missing terrain inside the manifest remains
in the report. Only new HTML destinations are published, with source preservation
and no silent replacement. The inline help states these distinctions.

Qualification uses the existing headless provider harness with `--study-context`:
it copies the complete demo folder into a path containing spaces/non-ASCII text,
verifies actual registration, generates the report, tests overwrite/missing-input
failure, compares report tables against direct R, and hashes source/copy files.
The installed backend/toolbox versions must be identified in a new isolated R
library. It does not update the existing trial profile or production libraries.

Package-level wrapper tests also compare reopened hierarchy/event summaries with
direct fluvgeo inputs using retained Cole Creek network evidence. Synthetic backend
tests cover native AOIs, partial/same-year dates, forensic-only drafts, relocation,
missing/changed links, terrain gaps, malformed schemas and unsupported types.
These do not qualify a general archive loader, new-project configuration UI,
broader client compatibility or a production installation procedure.

## Verification (2026-09-09)

The new provider ID is **`r:fgreviewstudyarea`**. Headless QGIS 3.44.14 with the
isolated `4.1.0-fg-cancel1` provider and installed fgqgis 0.0.0.9002 / fluvgeo
2026.09.9.9000 generated the Cole Creek report. Its 19 tables agreed with direct R
except the fresh validation timestamp. Missing inputs and overwrites returned
failure; original/copy inputs and the existing report were unchanged. The explicit
spatial guard ran, with no R warnings in the direct comparison. Evidence is kept
under ignored `dev/check-output/study-context-v1/`, not deployed to a user profile.
The final current-code run is `provider-final/`; the earlier `provider-1/` remains
supporting evidence before the overview-DEM wording clarification.

The fast suite passes 64 assertions; the explicit testthis wrapper suite passes
83, with no failures, skips or test warnings. fluvgeo's focused backend selection
passes 261 assertions. Runtime startup reports some packages built under R 4.6.1;
the qualification runtime is registry-selected R 4.6.0. Both repositories pass
strict reproducibleai context validation with existing modified-seed notices.

Both source packages built and installed into the isolated library. fgqgis
`R CMD check --no-manual --no-vignettes` completed with **Status: OK**. The scoped
fluvgeo check completed with zero errors/warnings and its two existing notes
(undeclared methods dependency and package-wide globals/imports); backend tests
and examples were excluded from that check and focused tests ran separately.
Checks used `_R_CHECK_FORCE_SUGGESTS_=false`; unavailable optional dependencies
were exercised through the workspace integration suite instead. Offline package
index diagnostics and fluvgeo's pre-existing R >= 4.1 build warning remain.
This is not a full external-service suite or release compatibility matrix.

The bounded desktop selection review below is now complete. This tested
workflow is not production-approved or a general deployment qualification. The earlier candidate's
cancellation evidence is retained separately; it was not repeated in this slice.

## Prepared analyst trial (2026-09-10)

`dev/check-output/desktop-trial-study-v1/` now contains a separate desktop-compatible
profile and a complete copied Cole Creek context folder. Actual provider execution
in that profile passed normal generation, overwrite/missing-input refusal, source
preservation and the 19-table direct-R comparison (fresh timestamp excepted).
It reuses the identified study-context development R library, not a production
library. Prior trial profiles and returned analyst artifacts were not changed.

Launch manifest schema 2 adds the registered algorithm, a whitelisted script name
and a relative-path hash inventory of copied inputs. The launcher checks these
before opening the profile; historical schema-1 network trials remain compatible.
Valid preflight, six in-memory malformed/changed-manifest refusal tests and the
old cancellation-profile preflight passed without starting QGIS or editing any
manifest. No R package/backend code changed in this preparation step, so package
checks were not repeated. This is not a complete dependency lock or an installer.

The [retained saved-context instructions](../workflows/qgis-desktop-trial.md#completed-trial-saved-study-area-2026-09-10)
request one ordinary run and feedback on context selection and restored scope.
The analyst has returned successful execution and clear interaction; see closure below.
No cancellation repeat or developer preparation is assigned to the analyst.

Desktop launch follow-up: the first agent-launched process used the correct trial
profile but had no main-window handle; the analyst could not find it with Alt+Tab.
Stopping only that identified trial process and relaunching outside the restricted
command environment produced a responding `Untitled Project — QGIS` main window.
This supports a launch-environment explanation, not a proven internal Qt diagnosis.
The launcher now says launch was requested, not that a usable window is confirmed.
Report execution and analyst feedback are now complete; do not repeat backend tests
or install another provider to address this window-launch issue.

## Analyst return and closure (2026-09-10)

**Analyst observation:** everything ran as expected and nothing was confusing.
The user also confirmed the relaunched QGIS application appeared on the taskbar.
This closes the one-run usability task; no further analyst repetition is needed.

**Verified:** the isolated profile's Processing history records
`r:fgreviewstudyarea`, provider `4.1.0-fg-cancel1`, the correct context input and
successful completion in 23.02 seconds. The retained output is
`Cole Créek inputs/analyst-report.html` inside `desktop-trial-study-v1/`.
Its 19 tables match the direct-R baseline except the fresh validation timestamp.
Every inventoried copied input retains its saved SHA-256, and launcher preflight
still passes. Review evidence is `desktop-return-checks.json` in that trial root.
The report/history were inspected read-only; no repeat execution was performed.

**Boundary:** this confirms saved-context reopening and reporting for this
Cole Creek/runtime/profile combination, not scientific acceptance, complete
hierarchy, a configuration editor or production deployment. Next develop the
analyst's ability to intentionally revise supplied context and save a new copy,
building on the existing backend writer and report rather than another runtime
investigation. The bounded implementation follows below.

## Bounded editing step (2026-09-10)

**Revise Study Area Details (experimental)** (`r:fgrevisestudyarea`) adds one
small editing operation to this same report workflow:

1. Review the saved report and select its context GeoPackage.
2. Optionally supply a new Study Area display name and/or an analyst scope note.
   Blank means keep; the note is appended as a paragraph, never substituted for
   earlier qualifications. At least one effective change is required. Fields do
   not automatically prefill from the selected context.
3. Choose a **new context GeoPackage beside the original** and a new HTML report.
   A temporary QGIS destination is unsuitable for the context's relative links.
4. Review the refreshed report. This is a draft revision, not acceptance.

The thin wrapper calls `fluvgeo::revise_study_context()`. Identities, native AOIs,
Streams, Reaches, Survey Events, forensic interpretations, terrain selections and
linked evidence remain unchanged. It cannot create a missing Study Area. Saving
and rendering are not one transaction: cancellation or rendering failure after
saving can leave the new context. Inspect it and use the read-only tool to retry
reporting. No full revision ledger or approval signature is supplied.

**Verified:** actual QGIS registration and execution with development fgqgis
0.0.0.9003 / fluvgeo 2026.09.10.9000 preserved the requested name and appended note
exactly. Other reopened context arguments were identical to the original. All 19
report tables matched direct R except the validation timestamp; source/copied
input hashes were unchanged. Context/report overwrites, missing input and blank
no-op edits returned failure without replacing existing outputs. Backend tests
also cover native AOI preservation, unchanged event associations, invalid names,
same-folder restrictions, missing Study Area and retained context on render error.

**Provider finding:** the first real run with `4.1.0-fg-cancel1` reported success
but reinterpreted literal backslashes in the analyst note as R escapes. The
requested-text comparison correctly rejected this result. A separate candidate,
**4.1.0-fg-text1**, corrects scalar string quoting and retains the unchanged
cancellation implementation. Twelve additional scalar cases passed exact R
round-trip, including Unicode/non-BMP text, quotes, control characters, literal
escapes and code-looking text. See the [small provider correction](../patches/r-provider-text/README.md).
Do not use the new free-text editor with the uncorrected serializer.

Evidence is retained under ignored `dev/check-output/study-edit-v1/`, using a new
isolated R library and `plugin-final/`. `provider-baseline/` retains the detected
failure; `provider-final/` retains the successful corrected execution. No existing
analyst profile, original context, production library or official plugin changed.
`provider-qualified/` is the final current-script run, also verifying that failed
attempts preserve the already-created revised context. It passes the same exact
text/context and 19-table comparison. The input form image and parameter
round-trip evidence are in `dialog/`; scalar regression evidence is in
`text-regression-final/`.

Current checks pass 284 focused backend assertions, 77 fast package assertions,
89 explicit testthis wrapper assertions and the 12 scalar transport cases, without
test failures or skips. The offscreen Qt form round-tripped all five parameters,
including a multiline note; this is not analyst usability confirmation. fgqgis's
source-package check reports **Status: OK**. The scoped fluvgeo check reports zero
errors/warnings and the same two existing notes (methods dependency and package
globals/imports); tests/examples were excluded and focused tests ran separately.
This does not include the full external-service suite. R 4.6.0 startup still notes
some dependencies built under 4.6.1. Both repositories pass strict reproducibleai
context validation with their existing modified-seed notices.

**Remaining:** analyst qualification of this new form, broader project fixtures,
general hierarchy/AOI/event editing and production provider maintenance. No further
cancellation or old saved-context analyst repetition is requested. The next useful
interaction is one intentional draft revision and review with this small form;
prepare that separately without changing an active QGIS session.

## Resumed editor trial preparation (2026-09-10)

The user resumed toolbox development after clarifying new-project design versus
legacy reconstruction. This next trial qualifies the existing name/note editor,
which is useful to both; it does not implement a general Define Study Area tool.
The [current analyst instructions](../workflows/qgis-desktop-trial.md) request one
intentional revision, with no cancellation repeat or developer work for the user.

Preparation now supports `--revise-context --prepare-desktop-trial`. Launch schema
3 names the exact editor/script, text-safe candidate and distinct same-folder
context destination, retaining the copied-input and plugin fingerprints. Schemas
1/2 remain supported. No R package, wrapper or scientific backend is changed by
this preparation; it uses the already-qualified installed fgqgis 0.0.0.9003 and
fluvgeo 2026.09.10.9000 in `study-edit-v1/r-library`, with provider 4.1.0-fg-text1.
The frozen report is the earlier combined presentation, not the new prospective
design/staging view selection. This distinction is stated in the analyst guide.

**Verified preparation:** `dev/check-output/desktop-trial-study-edit-v1/` contains
the new profile, copied Cole Creek inputs and schema-3 launch manifest. Actual
QGIS 3.44.14 / provider 4.1.0-fg-text1 execution preserved the requested name and
note exactly, with other reopened context arguments unchanged. All 19 report
tables agree with direct R except fresh validation time. Source and copied input
fingerprints match; overwrite, missing-input, blank-edit and report-collision
cases failed without replacing outputs. No direct-comparison R warnings occurred.

The new launcher passed valid preflight plus twelve in-memory refusal checks.
The earlier schema-2 trial passed its six refusal checks, and schema-1 preflight
still passed, all without launching QGIS or modifying saved manifests. Strict
context validation and documentation checks are part of completion verification.
R/package/wrapper code is unchanged, so package checks were not repeated for this
development-harness change. No visible QGIS session was launched; analyst usability
remains untested until the one-edit trial is returned.

## Analyst editor return (2026-09-10)

**Verified:** the analyst completed the requested edit and stopped before the
developer section. The saved Processing log identifies QGIS 3.44.14, provider
4.1.0-fg-text1 and the frozen trial library; execution succeeded in 14.83 seconds.
The submitted name was `Papillion Creek — editing trial`; ADD_NOTE was blank.
The output `Cole Créek inputs/analyst-revised.gpkg` preserves that name exactly,
including the em dash. Existing notes are unchanged, and restoring only the
name in memory makes all reopened context arguments identical to the original.
This return tests name-only editing, not analyst use of note appending.

The analyst chose `Cole Créek inputs/report.html` and saved
`Cole Créek inputs/analyst-edit-log.txt`; these valid alternate filenames do not
require a repeat run. All 19 report tables agree with a fresh direct-R rendering
from the revised context except the validation timestamp. All 17 inventoried
input files retain their preparation hashes. The returned context, report and
log retain their hashes across this read-only review. No edit was rerun, no
QGIS session was changed, and no source/package code was modified for the review.
The saved log is readable as Windows-1252, not UTF-8; the actual context and HTML
preserve the requested Unicode text. No data-corruption finding follows from
misreading that log as UTF-8.

Review script, comparison HTML and machine-readable evidence are retained under
ignored `dev/check-output/desktop-trial-study-edit-v1/analyst-return-review/`.
The comparison used the frozen library, not the current workspace backend, and
reported no warnings. **Analyst-confirmed:** the user found the form "crystal
clear" and said it matches the familiar ArcGIS Pro Script tool form layout.
The bounded editor trial is closed; this usability finding is user testimony,
not inferred from technical checks. No further run or developer
preparation is assigned to the analyst. This does not qualify the new reporting
views, general Study Area configuration or production deployment.

## Report-view selection (2026-09-11)

The user returned the new-study starter run, deferred report feedback and asked
to continue implementation. **Review Saved Study Area** and **Revise Study Area
Details** now add a REPORT VIEW selector: Terrain Development (compatible default),
Define Study Area, or Staging Report. The backend owns rendering through
`study_context_report()` and the appended `report_purpose` argument on revision.
No schema, identity, parentage, linked evidence or acceptance changes with the view.
No extra read/validation pass is added by the review wrapper.

Select Define Study Area to continue a new draft without returning to the combined
terrain presentation. Select Staging Report for saved reconstruction context;
it does not freshly inspect an unsaved archive/staging path. Neutral Study Area
reporting and full hierarchy editing remain unimplemented. A view-only change
uses the reviewer, not the editor; the editor still requires an effective name
change or appended note. Existing notes and all non-edited context remain intact.

QGIS metadata uses a zero-based selection (0 terrain, 1 definition, 2 staging).
An omitted value in ordinary-R wrapper tests preserves the old default; invalid
values fail visibly. This requires fgqgis 0.0.0.9005 and fluvgeo 2026.09.11.9000
in a new isolated development library. The old starter/editor analyst libraries
and profiles are not upgraded in place.

**Verified development qualification:** 353 focused backend assertions, 125
explicit testthis wrapper assertions and 92 fast package assertions pass without
failures or skips. Actual QGIS 3.44.14 / provider 4.1.0-fg-text1 runs qualify the
Staging reviewer (success, overwrite and missing-input cases) and Define Study
Area editor (success plus four refusal cases). Direct-R report comparisons and
context/input preservation checks pass. Both actual offscreen QGIS forms preserve
all three choices and default to Terrain Development; their screenshots were
reviewed for legibility. All three views also pass ordinary-R wrapper tests.

The initial developer run exposed a QGIS enum-parser ambiguity: a missing explicit
default consumed the last word of Staging Report. QGIS's own generated script
syntax supplies the final `0`; the corrected metadata is regression-tested.
Qualification evidence is under ignored `dev/check-output/report-views-v1/`;
failed initial parser runs remain there separately from successful final runs.
No visible analyst session or existing trial library was changed. This is
developer qualification, not analyst report-usability acceptance or deployment.

Native source-package build/check completes with fgqgis `Status: OK` and fluvgeo
`Status: 2 NOTEs` (existing undeclared `methods` use and package-wide globals/
imports), without check errors or warnings. Manuals/vignettes were excluded;
fluvgeo's full tests/examples were excluded and its focused suite ran separately.
Network-index and workstation `du` console diagnostics remain environmental
limitations; live external-service tests and production qualification were not
performed. Strict context validation and whitespace checks complete the
documentation review.
