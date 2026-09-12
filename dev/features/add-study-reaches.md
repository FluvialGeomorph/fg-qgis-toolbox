# Add Study Reaches

## Outcome

Continue the accepted stepwise Study Area workflow by recording meaningful Reach
names and their explicitly chosen parent Streams. An analyst can add one known
Reach now and continue later; no automatic segmentation or completion is implied.
This is configuration bookkeeping, not terrain analysis or archive conversion.

## Interface and boundaries

`fg_add_study_reaches.rsx` delegates to `fluvgeo::add_study_reaches()`; minimum
development versions are fgqgis 0.0.0.9008 and fluvgeo 2026.09.11.9003, with the
qualified R Provider 4.1.0-fg-text1 and Pandoc. Choose either:

- One exact saved Stream name and one new Reach name per line, without areas.
- A prepared whole GeoPackage table/polygon layer, exact Reach-name field and
  parent-Stream-name field. Live QGIS selections are not used.

Each parent must resolve to exactly one saved Stream. Ambiguous names can be
resolved by explicitly supplying Stream IDs through the R API; the form does not
guess. Trim Reach names and reject case-insensitive duplicates within a Stream,
including existing Reaches. Names may repeat across different Streams. Create
new local UUIDs; source IDs/other attributes are ignored, not reconciled.

Preserve existing Study Area, Streams, Reaches, acquired Survey Events and links.
Require an appended source/segmentation/assignment rationale. Save a new context
beside the original and a new report; refuse existing destinations. A rendering
failure or cancellation after saving may leave the context: inspect and continue
that copy, retrying read-only reporting. Do not recreate the same Reaches from an
older snapshot. This is not a transactional revision ledger or approval record.

Optional areas are valid nonempty finite CRS-defined XY polygons, not flowlines.
Appending requires the same geometry presence, polygon class and semantic CRS as
existing Reaches. Do not invent missing areas, reproject or infer containment.
Mixed known/unknown areas, later area assignment, identity rename/removal and
reconciliation remain separate work; this limitation is explicit in inline help.

The subsequent [Set Reach Areas](set-reach-areas.md) increment now supplies a
complete first area inventory or revises selected existing areas. Mixed missing/
supplied areas remain unsupported. The user clarified that polygons were not
historically required; their absence alone is not an analysis blocker.

The Define Study Area report lists Reach names and parent Streams, maps supplied
areas and identifies Streams with no Reach definitions. A Stream with a recorded
Reach may still need further divisions. Names-only Reach extents remain open;
planned observations are not created as acquired Survey Events.

## Representative evidence

The test uses the seven user-confirmed Papillion Stream areas and dissolved Study
Area boundary from fluvgeodata. The retained 2006 flowline names **Cole Creek R1**;
its association with **Little Papillion Creek** is already documented in
`fluvgeo/dev/scripts/cole-creek-terrain-report.R` and the prior Cole Creek structure
report. This is an explicit fixture interpretation, not a new spatial-assignment
rule. Wider line variants and corridor polygons are not confirmed Reach areas.

The main report therefore records only that known Reach, without an invented
boundary or Survey Event. The other six Streams remain unfinished. A second
names-only append uses a clearly synthetic label solely to test identity retention.
Original FileGDBs and supplied contexts are read-only evidence.

## Verification procedure and evidence boundary

Run focused backend context/report tests, the explicit testthis wrapper suite and
fast package tests sequentially. `prepare-reaches-check.R` creates a NEW isolated
library and fixtures. Run `qualify-qgis-provider.py --reaches-context` with that
library, `fixtures/streams.gpkg`, workstation R/Pandoc paths and the qualified
provider. Use another new root with `--inspect-dialog-only` for the offscreen form.
Ignored evidence belongs in `dev/check-output/study-reaches-v1/`.

The developer qualification checks source and names-only additions, parent/name
refusals, collisions, mixed modes, source hashes and independent direct-R report
agreement. Generated UUIDs differ between independent runs as intended; stored
IDs must remain stable when reopening and appending. Package checks do not prove
provider execution, and an offscreen form is not an analyst usability trial.

No production library, analyst profile, archive, FGDB schema or enterprise loader
is changed. fluvgeo owns the reusable behavior for QGIS and future Shiny clients;
the existing ArcGIS toolbox, ohwm2 and other consumers receive no automatic upgrade.

### Verified developer results (2026-09-11)

Actual QGIS 3.44.14 / R Provider 4.1.0-fg-text1 registered
`r:fgaddstudyreaches` and successfully ran source import and a progressive
names-only append. Eight refusal cases retained existing files and published no
new outputs: overwrite, blank rationale, missing name/parent fields, duplicate
existing Reach, unknown parent, incomplete names-mode inputs mixed with source,
and report collision. The mixed/incomplete case stops at the paired-name check;
the explicit wrapper suite separately exercises two fully supplied modes.

Direct-R evidence confirms exact parentage, unchanged other context, stable
persisted IDs, independently generated new UUIDs and matching report tables.
Source archive and copied fixture hashes are unchanged. All ten actual Qt inputs
round-trip correctly offscreen; the map and form screenshot were reviewed. The
form scrolls to rationale/outputs; this is not a new analyst usability finding.

The focused backend context/report suite passed 474 assertions; the final Reach
subset passed 50 (including two additional Reach-only map assertions). Fast
fgqgis tests passed 131 assertions; the final explicit testthis wrapper suite
passed 159. No test failures, assertion warnings or skips
occurred; package startup still reports packages built under R 4.6.1 on R 4.6.0.

Native source builds/checks complete with fgqgis `Status: OK` and fluvgeo
`Status: 2 NOTEs` (existing undeclared `methods` use and package-wide globals/
imports), without check errors or warnings. Manuals/vignettes are excluded;
fluvgeo's full tests/examples are excluded and fluvgeodata is unavailable to that
isolated package check. Focused and explicit workspace tests use sibling data.
Network-index and workstation `du` diagnostics are environmental limits, not
live-service qualification. Generated help, schema/API records and current plans
are aligned; production promotion remains separate.

Strict reproducibleai validation passes in both repositories, with only existing
repository-owned seeded-content notices. Preserve those maintained customizations.
Changes remain uncommitted alongside the preceding boundary/Stream increments.
