# Review Saved Study Area

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

The [current analyst instructions](../workflows/qgis-desktop-trial.md#current-trial-saved-study-area-2026-09-10)
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
