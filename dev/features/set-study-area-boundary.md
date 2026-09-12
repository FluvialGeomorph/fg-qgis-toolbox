# Set Study Area Boundary

## Purpose

Move a saved new-study draft beyond a name and notes: let the analyst explicitly
define its geographic extent and see it in the Define Study Area report. The same
operation can attach a reconstructed legacy extent once its Study Area identity
is supplied. It does not choose the extent or establish customer approval.

## Contract

`fg_set_study_boundary.rsx` is a thin adapter to
`fluvgeo::revise_study_context(study_area_boundary = ..., add_note = ...)`.
It requires fgqgis 0.0.0.9006 and fluvgeo 2026.09.11.9001 in the separate development
runtime. The ordinary name/note editor and its defaults remain unchanged.

Inputs are a saved context, a boundary GeoPackage, an exact layer name and required
source/rationale text. Read the whole named layer, not a QGIS selection; it must
contain exactly one valid, nonempty, CRS-defined XY POLYGON or MULTIPOLYGON.
This is a bounded import interface, not a general requirement that Study Areas
are contiguous. Multipart islands/holes are retained. Analysts deliberately
combine/export multiple selected features beforehand. HUC delineation remains
optional; the Papillion test uses the user-confirmed union, not an inferred rule.

Only geometry is imported. Preserve native coordinates/CRS and the existing study
identity/name; ignore source attributes explicitly rather than treating them as
hierarchy fields. Append a labeled supplied/replaced boundary note. Save a **new**
same-folder context and Define Study Area HTML with an offline boundary map.
Existing destinations are refused before saving; render failure/cancellation can
leave the new context for inspection and read-only report recovery.

No dissolve, repair, reprojection, clipping, child-AOI edits, Stream/Reach creation,
terrain acquisition or enterprise loading occurs. Existing linked evidence remains
pinned. A boundary change does not assert that children lie inside it. Notes record
an analyst statement, not a structured provenance ledger or an approval signature.
The boundary geometry is embedded: its source GeoPackage is not a newly pinned link.

## Verification boundary

Tests cover synthetic new and populated contexts and the retained Papillion HUC12
fixture. Backend checks, ordinary-R wrapper tests, actual provider execution and
offscreen form inspection are separate evidence. Developer artifacts live in
ignored `dev/check-output/study-boundary-v1/`; no production library or earlier
analyst profile is upgraded. User report feedback remains deferred to the next
round; no repeat starter trial is required.

**Verified, 2026-09-11:** 387 focused backend assertions, 136 explicit testthis
wrapper assertions and 105 fast package assertions pass without failures or skips.
Final wrapper run has no test warnings. Fixture preparation uses R's initialized
GDAL resources before isolating the ordinary-R wrapper probe.

Actual QGIS 3.44.14 / R Provider 4.1.0-fg-text1 registers
`r:fgsetstudyboundary` with six parameters and multiline rationale. The Papillion
run succeeds; overwrite, blank rationale, absent layer, multiple features and
report collision fail without publishing fresh outputs or changing existing ones.
Direct-R comparison confirms native geometry/CRS, identity, other context, exact
Unicode/quoted/backslash/newline rationale, and report-table agreement. Source
archive, fixture and copied input fingerprints remain unchanged. The actual Qt
form round-trips its values and its screenshot is readable.

The first developer invocation omitted the workstation Pandoc path, demonstrating
the documented partial-output boundary: context retained, reporting failed, no
successful Processing result. It remains under `provider/`, separate from the
successful `provider-final/` run. This was a developer setup omission, not a reason
for the analyst to repeat prior work. Visual map review also prompted fewer,
angled longitude labels; no boundary coordinates or CRS were changed.

Native source builds/checks finish with fgqgis `Status: OK` and fluvgeo
`Status: 2 NOTEs` (existing undeclared `methods` use and package-wide globals/
imports), no check errors or warnings. Manuals/vignettes are excluded; fluvgeo's
full tests/examples are excluded in favor of the focused offline suite above.
Network-index and workstation `du` console diagnostics do not establish live
service qualification. Final source-template verification uses the checked
fluvgeo tarball in the isolated library; earlier analyst libraries stay frozen.
The final packaged rerun is `provider-qualified/`: all six cases and direct-R
comparisons pass, its installed report template matches the source SHA-256, and
the revised map image has readable labels. Strict reproducibleai validation passes
for both repositories, as do final whitespace checks. Report usability remains
an analyst question, not a conclusion from these developer checks.

Reproduce with `prepare-boundary-check.R` in a new output root, then the shared
`qualify-qgis-provider.py --boundary-context` harness using its `fixtures/draft.gpkg`
and `r-library`. Use the workstation Pandoc/R paths and qualified provider described
in the developer workflow. Add `--inspect-dialog-only` in another new output root
for the offscreen form check. These are developer steps, not an analyst assignment.

## Analyst report feedback

The user reviewed the Papillion Define Study Area report and confirmed that its
stepwise layout is clear, then authorized the next development step. This is
report-presentation feedback, not a new desktop form trial or approval of study
scope. Retain the known/next-decision presentation while adding Streams.
