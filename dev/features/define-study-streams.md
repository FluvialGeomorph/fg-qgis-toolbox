# Define Initial Study Streams

## Outcome

Continue a saved Study Area by explicitly choosing its initial Streams. The user
confirmed the Define Study Area report's clear stepwise layout; this increment
adds a numbered Stream inventory and optional area map while leaving Reach
divisions as the next design decision.

The user accepted this report increment and requested continued development on
2026-09-11. This is report feedback, not an independently observed desktop form
test or evidence that a third-party analyst qualified every workflow.

## Interface and limits

`fg_define_study_streams.rsx` delegates to `fluvgeo::define_study_streams()`.
Requires fgqgis 0.0.0.9007 / fluvgeo 2026.09.11.9002 and the qualified development
R Provider. Two mutually exclusive entry modes:

- Enter one Stream name per line, without areas or acquired data.
- Supply a prepared GeoPackage layer/table, exact layer name and text name field.
  Every row is imported; a live QGIS selection is not used. Optional areas are
  valid nonempty CRS-defined XY polygons, not flowlines. Only chosen names and
  geometry are imported; other source attributes/IDs are explicitly ignored.

Both require source/naming/segmentation rationale. HUC conventions are optional;
Papillion uses the user-confirmed choice. Names are trimmed and must be nonempty
and case-insensitively unique in this initial-definition interface, not a new
global naming or storage rule.

Create new local Stream UUIDs under the existing Study Area; save a new same-folder
context and report. Preserve original context, boundary, notes and linked evidence;
append the rationale. Native area coordinates and CRS are retained. The report's
display CRS may differ without changing stored geometry.

Existing Streams, Reaches, Survey Events or a linked network are refused, including
an empty supplied table. Append/rename/removal and archived-ID reconciliation need
identity-aware editing. Continue the successful output: repeating definition from
the original draft would generate another set of UUIDs. No Reach/event creation,
dissolve, clipping, reprojection, containment/coverage approval or enterprise
loading occurs. Report failure can leave the saved context; inspect and retry
read-only reporting rather than redefining Streams.

## Developer verification

Tests cover names-only drafts, malformed inventories and seven retained Papillion
areas, separately from actual QGIS execution. Artifacts belong in ignored
`dev/check-output/study-streams-v1/`. Existing analyst profiles/production libraries
remain unchanged; new-form usability is not inferred from previous report feedback.

Use `prepare-streams-check.R` in a new output root, then
`qualify-qgis-provider.py --streams-context` with its `fixtures/draft.gpkg` and
`r-library`, workstation R/Pandoc paths and qualified provider. An additional new
root with `--inspect-dialog-only` checks the form offscreen. These are developer
steps, not a repeat analyst assignment.

Verified on this workstation: 426 focused backend assertions, 148 explicit testthis
wrapper assertions and 118 fast package assertions pass without test failures,
warnings or skips. Actual QGIS 3.44.14 / R Provider 4.1.0-fg-text1 executes both
names-only and seven-area source modes successfully. Six refusal cases preserve
existing files and publish no new outputs: overwrite, blank rationale, missing
name field, existing inventory, mixed modes and report collision.

Direct-R checks confirm exact names/rationale, native area WKB/CRS, existing
Study Area/other context, distinct local IDs with correct parentage, and matching
report tables. Independently generated UUIDs differ as intended; persisted IDs
remain stable on reopening. Source archive and copied fixture hashes are unchanged.
Actual offscreen Qt parameters round-trip correctly; the map and form screenshot
were reviewed. The eight-parameter form scrolls to its output fields; analyst
usability of this new form remains untested. No desktop session was launched.

Native source builds/checks complete with fgqgis `Status: OK` and fluvgeo
`Status: 2 NOTEs` (existing undeclared `methods` use and package-wide globals/
imports), without check errors or warnings. Manuals/vignettes are excluded;
fluvgeo's full tests/examples are excluded, with focused offline tests run above.
Network-index and workstation `du` console diagnostics remain environmental
limitations, not live-service qualification. No production deployment is implied.
