# Set Reach Areas

## Outcome and contract

Supply areas to already named Reaches or revise selected existing areas without
recreating their identities. The thin `fg_set_reach_areas.rsx` adapter delegates
to `fluvgeo::set_study_reach_areas()`. Development versions: fgqgis 0.0.0.9009 /
fluvgeo 2026.09.11.9004; qualified R Provider 4.1.0-fg-text1 and Pandoc.

Prepare a GeoPackage polygon layer with a text field containing saved Reach IDs
from the context's `reaches` table (also in the report's Supporting record).
Explicitly join/copy those IDs to chosen polygons. Read every row in the exact
layer, not a live selection. Match exact distinct IDs, not names, row positions
or overlap; ignore other attributes. Preserve row order, scalar data, identities,
parentage, events, other geometry and linked evidence. Append source/rationale.

For names-only Reaches, supply one valid finite CRS-defined XY polygon per recorded
Reach together. Once areas exist, revise selected rows in the same semantic CRS
and polygon class. Mixed missing/supplied areas remain outside schema 1. This
compatible increment does not settle a future partial-area storage design.
No repair, dissolve, reprojection, clipping, containment approval or identity
reconciliation occurs. Save a new same-folder context and new report; existing
outputs are refused. Report failure/cancellation can leave a context; retain it
and retry read-only reporting. No production library or analyst profile is changed.

## Geographic interpretation

The user clarified that historic workflows never required a Reach polygon.
Absence is not failed historical compliance or, by itself, a barrier to analysis.
A `dem_hydro` extent may supply a manufactured legacy reconstruction polygon.
This is an option, not a universal delineation rule or evidence of a historical
analyst decision. New projects remain free to define areas without acquired data.

The Cole Creek test explicitly uses the rectangular extent of retained
`y2016_R1.gdb / dem_2016_hydro_50`, in its native CRS, for the existing Cole Creek
R1 identity under Little Papillion Creek. The report calls it a **candidate**.
It is not a valid-cell mask (NoData margins are included), original delineation,
or approved multi-period Reach boundary. No union/intersection across surveys is
inferred. The source/method/CRS/bounds are saved in the ignored fixture evidence;
the context note records the selected dataset and limitation. Structured external
area-source provenance remains future work, not a new schema field.

The form accepts prepared polygons, not a DEM directly. The developer fixture
derives its rectangle with terra/sf metadata operations; a general analyst-facing
DEM-to-area tool is not implemented by this increment.

## Test-harness findings

Native polygon WKB and semantic CRS checks remain exact. The supplementary JSON
extent comparison allows less than `1e-8` metre rounding: the initial check found
about `3.73e-9` metre loss from decimal serialization, not geometry movement.
The earlier failed evidence run is retained separately from the final qualification.
The direct wrapper fixture also uses the established scoped environment cleanup
after reading a raster, before testing the production spatial guard; that guard
and the installed provider were not relaxed or changed.

## Verification

Run focused context/report tests and explicit testthis wrappers using sibling
fluvgeodata, then package tests/checks. `prepare-reach-areas-check.R` makes a new
isolated library and fixtures, preserving archive hashes. Qualify actual QGIS
with `qualify-qgis-provider.py --reach-areas-context`, its `fixtures/reaches.gpkg`
and library, plus an additional new output root with `--inspect-dialog-only`.
Generated evidence belongs in `dev/check-output/reach-areas-v1/`.

Tests cover reordered complete assignment, selected revision, native WKB/CRS,
existing events/identities, missing/duplicate/unknown IDs, incomplete initial
areas, incompatible replacements and destination safety. Actual QGIS results are
compared independently with direct R, including report tables and source hashes.
Offscreen parameter checks are not an analyst usability trial. General terrain
coverage, multi-period boundary suitability, archive conversion, production
deployment and enterprise loading remain unqualified by this bounded test.

### Verified developer results (2026-09-11)

- 506 focused backend assertions, 167 explicit testthis wrapper assertions and
  144 fast package assertions pass without test failures, assertion warnings or
  skips. Existing R 4.6.1-built package startup warnings on R 4.6.0 remain.
- Actual QGIS 3.44.14 / R Provider 4.1.0-fg-text1 registers `r:fgsetreachareas`.
  Initial assignment and revision run successfully. Six refusal cases preserve
  files and publish no new outputs: overwrite, blank rationale, missing layer,
  unknown ID, missing ID field and report collision.
- Final evidence in `provider-qualified/` confirms direct-R context/report-table
  agreement, native WKB/CRS, unchanged IDs/parentage/other context, DEM bounds and
  source/copy hashes. The eight-case run is separate from the earlier metadata
  comparison failure retained in `provider/`.
- All seven form parameters round-trip through the real offscreen Qt dialog.
  Form and report-map images were reviewed; no desktop session was launched or
  new analyst usability result inferred. The rectangle is visible within the
  Little Papillion Stream area; this visual observation is not a containment test.
- Native source builds/checks finish with fgqgis `Status: OK` and fluvgeo
  `Status: 2 NOTEs` (existing undeclared `methods` use and package-wide globals/
  imports), no check errors or warnings. Manuals/vignettes are excluded;
  fluvgeo's full tests/examples are excluded and its package check lacks the
  suggested fluvgeodata package. Focused workspace tests above exercise that data.
  Network-index/Windows `du` diagnostics do not qualify live services.
- Strict reproducibleai validation passes in both repositories, with only the
  existing repository-owned seeded-content notices. Preserve those customizations.
  Changes remain uncommitted alongside preceding increments; no production
  installation, archive mutation, FGDB change or downstream client upgrade occurs.
