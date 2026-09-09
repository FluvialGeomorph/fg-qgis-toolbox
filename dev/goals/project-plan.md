# Project plan

## Outcome

Provide an incremental, open-source QGIS desktop workflow using the same fluvgeo
science as Shiny. Support Study Area configuration and description, terrain
development, forensic reconstruction of archived projects, and eventual FGDB
preparation without replacing production ArcGIS prematurely.

## Current scope

Package and AI-assisted foundations are implemented. The first experimental
network-review wrapper now delegates to the fluvgeo Terrain Development report.
The actual QGIS R Provider can invoke fluvgeo and produce a report whose tables
agree with direct R, without changing source data. The observed environment
conflicts have been addressed. This establishes a working connection for one
read-only tool, not complete interoperability. See the
[qualification summary](../features/qgis-provider-qualification.md).

## Next bounded milestone

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

Next return to the Study Area workflow: inspect the existing saved-context/folder
interface in fluvgeo and specify the smallest read-only QGIS extension that can
reopen that context, rather than accepting only a network GeoPackage. Reuse the
current report and backend contract; do not create new scientific logic or
silently infer missing hierarchy. Provider maintenance need not become another
analyst testing loop or block this development work.

Success requires direct-R agreement **and** actual provider execution, useful
inline help, explicit failures and unchanged source evidence. Package tests alone
do not authorize promotion. Do not expand into terrain extraction, archive-wide
migration or enterprise loading as part of that first wrapper.

## How this advances the larger workflow

The tool accepts only a network bundle: it cannot reopen the full Study Area,
event inventory or terrain links from that file. Missing context remains visible.
Use the returned desktop trial's feedback and the
[fluvgeo plan](../../../fluvgeo/dev/goals/project-plan.md) to select the next
study-context capability. Complete folder binding, broader client qualification
and deployment remain separate work. The accepted GeoPackage-vector/GeoTIFF-terrain
folder design is unchanged; runtime maintenance is not an ongoing research goal.
