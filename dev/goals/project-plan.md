# Project plan

## Outcome

Provide an incremental, open-source QGIS desktop workflow using the same fluvgeo
science as Shiny. Support Study Area configuration and description, terrain
development, forensic reconstruction of archived projects, and eventual FGDB
preparation without replacing production ArcGIS prematurely.

## Foundational workflow requirements

Follow the shared [reporting intent](../../../fluvgeo/dev/goals/reporting-intent.md)
when designing future tools:

- **New project / Define Study Area:** progressively capture customer purpose,
  candidate scope, Streams/Reaches and planned observations. Open choices are
  expected; do not require an archive, FileGDB staging or a completed acquisition.
- **Legacy project / Staging Report:** recover intended hierarchy and actual
  survey evidence from selected artifacts, preserve competing interpretations,
  and qualify the configured FileGDB-to-GPKG migration separately.
- Both work on one shared Study Area configuration and support a neutral
  **Study Area Report**. Terrain Development explains terrain inputs/processing/
  limitations using that same definition. Do not create duplicate schemas,
  mandatory report-per-step paperwork or a second client-side validator.

Retain human scope/segmentation decisions; automate mechanical bookkeeping.
Distinguish planned campaigns from actual Survey Events and open design choices
from missing historical facts. Test both entry cases before claiming general
configuration support. These are future tool requirements: the existing saved-
context reviewer and name/note editor are narrower. The first new-project starter
and report-view selectors are now implemented below; general configuration remains
open.

## Current scope

**Resumed by the user, 2026-09-10:** the foundational new-project versus legacy
workflow clarification is recorded. The existing bounded name/note editor's
analyst run is technically verified and the user found its form crystal clear
and familiar from ArcGIS Pro Script tools. That trial is closed. This is a
shared-context building block, not yet a Define Study Area wizard or migration
converter. The accepted
[FileGDB staging -> GPKG desktop -> FGDB path](../../../FG-architecture/dev/decisions/adr-0005-analyst-staged-archive-migration.md)
is grounded in the new `FG-filedata` workspace folder. Complete staging schemas
and conversion qualification remain separate from this small desktop form trial.

Package and AI-assisted foundations are implemented. The first experimental
network-review wrapper now delegates to the fluvgeo Terrain Development report.
The actual QGIS R Provider can invoke fluvgeo and produce a report whose tables
agree with direct R, without changing source data. The observed environment
conflicts have been addressed. This establishes a working connection for one
read-only tool, not complete interoperability. See the
[qualification summary](../features/qgis-provider-qualification.md).

## Next bounded milestone

The [one-edit analyst return](../features/review-study-area.md#analyst-editor-return-2026-09-10)
passes technical review: the requested name is exact, blank ADD_NOTE preserves
existing notes, other context and inventoried inputs are unchanged, and report
tables agree with direct R. The analyst confirmed clarity and familiarity; no
repeat execution or developer work is assigned to the analyst.

**Implemented next slice:** [Start Study Area](../features/start-study-area.md)
creates a named draft and optional scope notes using the shared context, with a
short Define Study Area report. It requires no archive, terrain or completed
survey. Actual isolated QGIS execution and offscreen form qualification passed
on 2026-09-11. The one-start analyst return is technically verified; the user
explicitly defers report feedback and asks development to proceed. The next slice
is implemented and developer-qualified: explicit report-view selection on
reopening/revision, preserving the existing
Terrain Development default and the frozen analyst library/profile. Do not call
this a general planning wizard. See [the report-view contract](../features/review-study-area.md#report-view-selection-2026-09-11).
The execution history below remains supporting evidence, not extra assigned work.
No repeat analyst run is required now. The next functional increment should expand
progressive Study Area configuration; report feedback is deferred to the next round,
not inferred from successful execution.

The analyst trial has been returned and reviewed: desktop report generation
works, but Cancel was delayed and a complete report remained after QGIS reported
failure. See the [return findings](../features/qgis-provider-qualification.md#analyst-trial-return-2026-09-09).

An isolated provider candidate now passes eight cancellation/exit regression
cases and the real Cole Creek/direct-R comparison. It checks cancellation without
waiting for R console output and returns no successful results for canceled runs.
See [the measured candidate results](../features/qgis-provider-qualification.md#cancellation-candidate-2026-09-09).

The [candidate desktop check](../features/qgis-provider-qualification.md#desktop-cancellation-confirmation-2026-09-09)
is now complete: the log confirms the candidate, the analyst reports immediate
cancellation, and no requested HTML was left behind. No further repetition of
this analyst test is needed. The
[upstream/maintenance review](../patches/r-provider-cancellation/README.md#maintenance-review-2026-09-09)
is complete, with a local contribution draft and an upstream-first recommendation.
Publishing that draft and adopting a maintained provider remain separate choices;
the candidate does not change the official plugin, existing profile, R scientific
methods or production deployment. The bounded cancellation test is closed;
broader release/dependency qualification remains separate.

The next slice is implemented: [Review Saved Study Area](../features/review-study-area.md)
reopens supplied hierarchy, event inventory, notes and pinned local evidence links
through fluvgeo's new context GeoPackage. It reuses the existing report and
validation, not another scientific implementation. The Cole Creek folder demo
now saves this context and renders from the reopened records.

The saved-context desktop trial is complete: the analyst reports everything ran
as expected with no confusion. Processing history confirms success, all 19 report
tables match direct R apart from validation time, and copied input hashes are
unchanged. See [the closure](../features/review-study-area.md#analyst-return-and-closure-2026-09-10).
No further runtime or cancellation repetition is needed for this bounded slice.

The [first bounded editor](../features/review-study-area.md#bounded-editing-step-2026-09-10)
now changes an existing Study Area display name and/or appends a scope note, saving
a new same-folder context and refreshed report through fluvgeo. It preserves all
other records and linked evidence. Free-text entry exposed a provider escaping
defect; a separate development text correction is part of this qualification, not
an update to the analyst's installed profile. Next qualify this small editing form
with the analyst before expanding into hierarchy/AOI/event configuration. No
automatic identity reconciliation, in-place overwrite or enterprise loading is
implied. Production dependency/provider promotion remains separate.

Success requires direct-R agreement **and** actual provider execution, useful
inline help, explicit failures and unchanged source evidence. Package tests alone
do not authorize promotion. Do not expand into terrain extraction, archive-wide
migration or enterprise loading as part of that first wrapper.

## How this advances the larger workflow

The original tool still accepts only a network bundle. The new context entry point
reopens explicitly saved parent records and terrain links; it does not infer these
from a network. Missing context remains visible.
Use the returned desktop trial's feedback and the
[fluvgeo plan](../../../fluvgeo/dev/goals/project-plan.md) to select the next
study-context capability. Complete folder binding, broader client qualification
and deployment remain separate work. The accepted GeoPackage-vector/GeoTIFF-terrain
folder design is unchanged; runtime maintenance is not an ongoing research goal.
