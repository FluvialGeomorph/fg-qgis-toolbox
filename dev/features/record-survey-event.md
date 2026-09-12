# Record Survey Event

## Outcome and boundary

Add one acquired Survey Event under an already named Reach, then refresh the
same evolving Define Study Area report. `fg_record_survey_event.rsx` delegates to
`fluvgeo::record_study_survey_event()`; development versions fgqgis 0.0.0.9010 /
fluvgeo 2026.09.11.9005. Use the qualified development R Provider 4.1.0-fg-text1.
This is acquisition inventory, not an asset importer or production release.

The backend API is additive and reuses the existing context schema; no dependency
or storage migration is introduced. Existing callers in the ArcGIS toolbox,
ohwm2 and RegionalCurve are unchanged. fluvgeodata is read-only test evidence.
Only isolated development libraries contain these versions; production clients,
analyst profiles and release workflows are not upgraded.

Choose the exact saved Reach ID from the context or report's Supporting record.
Supply a known acquisition date (year, month or day precision), source/delivery
reference and evidence note. Unknown month/day remain missing integers; invalid
calendar dates and periods wholly in the future are refused. Planned campaigns
and undated historical evidence remain in notes, not fabricated acquired events.
No polygon, DEM or legacy archive is required to record an evidenced acquisition.

Existing hierarchy, geometry, event identities, notes and evidence links remain
intact. Each entry receives a new local UUID. An exact repeat of Reach, date
precision/value and trimmed source reference is refused; alternate labels or date
precision still need analyst duplicate review. Multiple acquisitions per year are
allowed. General event editing and identity reconciliation are separate work.

Save a new context beside the original and a new report. Existing outputs are
refused. Reporting failure/cancellation may leave a saved context: retain it and
retry read-only reporting. The source reference is stored text, not a verified
file link; no source is opened, copied or converted by this tool.

## Report and example

The main report shows Stream, Reach, acquisition, precision and source reference;
Supporting record retains IDs and evidence notes. The next action is to associate
and assess terrain files, not assume comparisons are ready. No complete inventory,
valid-cell coverage or approved multi-period boundary is inferred.

The Cole Creek example adds previously user-confirmed 2006, 2010 and 2016
acquisitions under the existing R1. Month/day stay unknown. Developer fixtures
check retained source labels and hashes, but the tool itself does not derive dates
from filenames or independently verify acquisitions. The 2016 DEM-extent Reach
polygon remains a reconstruction candidate, not a confirmed multi-period area.
Copperas dates remain unknown and are not invented for this example.

## Verification procedure

Run focused backend tests, fast package tests and the explicit testthis wrapper
suite using sibling fluvgeodata. `prepare-survey-event-check.R` prepares a new
isolated package library and fixtures. Run `qualify-qgis-provider.py` with
`--survey-event-context`, `fixtures/study.gpkg` and the qualified provider; use a
second new output root for `--inspect-dialog-only`. Evidence belongs under
`dev/check-output/survey-events-v1/`, not package assets or source archives.

Actual provider qualification exercises three successive acquisitions and seven
refusals: duplicate, invalid date, future plan, unknown Reach, missing evidence,
context overwrite and report collision. Independent direct-R comparisons normalize
only the newly generated event UUID; prior IDs/values must agree exactly. Compare
report tables, unknown date values, source/copy hashes and dialog parameters.
Offscreen form checks do not establish analyst usability or production support.

Next: expose explicit terrain-asset association and its review using shared intake
capabilities. Do not expand this entry tool into DEM analysis or FGDB loading.

### Verified developer results (2026-09-11)

- 546 focused backend assertions, 187 explicit testthis wrapper assertions and
  157 fast package assertions pass without test failures, assertion warnings or
  skips. Existing R 4.6.1-built package startup warnings on R 4.6.0 remain.
- Actual QGIS 3.44.14 / R Provider 4.1.0-fg-text1 registers
  `r:fgrecordsurveyevent`. All ten execution/refusal cases pass. Final evidence in
  `provider-final/` confirms direct-R context/report-table agreement, retained
  identities, year-only integer missing values and unchanged source/copy hashes.
- The initial passing run in `provider/` exposed an unnecessarily technical
  invalid-date error. A targeted backend message improvement and regression
  assertion were followed by the full final provider qualification; invalid dates
  now receive a plain-language calendar-date error. Scientific behavior is unchanged.
- All seven parameters round-trip through the actual offscreen Qt dialog. The
  form and report map were inspected. No desktop session or new analyst usability
  result is implied; existing analyst profiles and production installations remain
  unchanged. This is not terrain coverage, migration or FGDB qualification.
- Native source builds/checks finish with fgqgis `Status: OK` and fluvgeo
  `Status: 2 NOTEs` (existing undeclared `methods` use and package-wide globals/
  imports), with no check errors or warnings. Manuals/vignettes are excluded;
  fluvgeo's full tests/examples are excluded and its package check lacks suggested
  fluvgeodata. The focused workspace tests above exercise retained data. Repository
  index-access and Windows `du` diagnostics remain environmental limitations.
- Strict reproducibleai validation passes in both repositories with five existing
  seeded-content customization notices, which are preserved. Changes remain
  uncommitted; preceding uncommitted toolbox increments are retained.
