# Analyst desktop trials

## Returned trial: start a Study Area (2026-09-11)

**Technical review complete; report feedback deferred by the user.** The saved
draft and report match the requested name-only start. No repeat run is requested.
The following instructions are retained as history, not a current assignment.
Development now advances report-view selection for reopening/revision; its
updated packages do not replace this frozen analyst profile.

**Start one test study, review it, then stop.** The developer checks are complete.
This trial needs no source dataset, archive, DEM or survey. It checks whether the
new-study entry and its report are understandable, not whether a real project is
fully configured. Earlier reviewer/editor/cancellation trials below are closed.

Save your work and close existing QGIS windows. In PowerShell, run:

```powershell
& 'C:\workspace\FluvialGeomorph\fg-qgis-toolbox\dev\scripts\start-qgis-trial.ps1' -TrialDirectory 'C:\workspace\FluvialGeomorph\fg-qgis-toolbox\dev\check-output\study-start-qgis-v1\desktop-qualified'
```

This opens a separate **QGIS desktop window**, visible on the taskbar/Alt+Tab.
It is not a browser tab. No window was launched during developer preparation;
if your launch produces no visible window, tell us rather than starting copies.
It uses the isolated text-safe provider 4.1.0-fg-text1, fgqgis 0.0.0.9004 and
fluvgeo 2026.09.10.9001. Your normal profile and production libraries are unchanged.

1. Search the Processing Toolbox for **Start Study Area (experimental)**.
2. Set **STUDY NAME** to a clearly labelled test, such as `New study — desktop trial`.
   In **SCOPE NOTES**, optionally describe a customer question or an open scope
   decision. Leaving it blank is allowed. No input file is requested.
3. Choose these persistent outputs inside the trial folder shown by the launcher:
   - **CONTEXT:** `New Créek drafts/analyst draft.gpkg`
   - **OUTPUT:** `analyst report.html`
   Do not choose `developer draft.gpkg` or any already-created report.
4. Run once and open the **Define Study Area** report. Check that your name/notes
   appear and that missing boundaries, Streams, Reaches and observations are
   presented as design decisions, not archive-repair failures.

Save the Processing log as `analyst-start-log.txt` in the trial folder and tell
us whether the form and next decisions were clear. **That completes your part.**
No Cancel test, package installation or developer section is assigned to you.
Keep the outputs even if a run fails; do not overwrite or delete them. Starting
again creates another identity. Report recovery should reopen the saved context,
not start another study. Existing review/edit tools still use the combined Terrain
report; report-purpose selection for continued drafts is separate upcoming work.

### Developer evidence boundary

Preparation uses `qualify-qgis-provider.py --start-context --prepare-desktop-trial`
with no `--input`, the isolated `study-start-qgis-v1/r-library`, and a new output
root. Schema 4 contains no source input: it identifies the starter, provider,
script/plugin fingerprints and new context/report destinations. The launcher
checks these destinations and refuses already-used suggested paths.
`--inspect-dialog-only` checks the Qt form without invoking R. The first failed
developer expectation is retained in `desktop-trial/`; **use `desktop-qualified/`
for the analyst**, where all six cases and direct-R comparison passed.

Provider output handling creates missing parent directories before R runs;
direct R still requires existing directories. This is not fluvgeo creating a
standard project hierarchy, and rejected runs can leave provider-created empty
directories. Review returned files/logs without repeating the creation operation.
See [the qualification record](../features/start-study-area.md#actual-provider-qualification-2026-09-11).

## Completed trial: revise Study Area details (2026-09-10)

**Completed:** the analyst's name-only edit preserved
existing notes, other context and original inputs; report tables match direct R.
The analyst found the form crystal clear and familiar from ArcGIS Pro Script
tools. No repeat run or developer preparation
is required from the analyst. See the [return evidence](../features/review-study-area.md#analyst-editor-return-2026-09-10).
The instructions below are retained for reproducibility, not as a new assignment.

**One intentional edit, then stop.** This resumes the bounded form test left
unfinished before the workflow clarification. It tests a shared editing building
block for either project origin, not new-study configuration or legacy conversion.
The copied Cole Creek fixture and frozen development library still render the
earlier combined **Terrain Development** report; the new report-purpose views
are not part of this form trial.

Save work and close existing QGIS windows. In PowerShell, run:

```powershell
& 'C:\workspace\FluvialGeomorph\fg-qgis-toolbox\dev\scripts\start-qgis-trial.ps1' -TrialDirectory 'C:\workspace\FluvialGeomorph\fg-qgis-toolbox\dev\check-output\desktop-trial-study-edit-v1'
```

This opens a separate QGIS desktop window using the qualified development text
provider **4.1.0-fg-text1**. It does not update your normal profile or production
R libraries. Find the window on the taskbar/Alt+Tab; if none appears, tell the
developer rather than launching additional copies. Preparing the trial does not
itself launch a visible window.

1. Search the Processing Toolbox for **Revise Study Area Details (experimental)**.
2. Set **INPUT** to `Cole Créek inputs/cole-creek-study.gpkg` in the trial folder.
   Do not select `study revised.gpkg`, which is developer-check output.
3. Enter a small intentional **NEW_NAME** and/or **ADD_NOTE**. For example, use
   `Papillion Creek — editing trial` and a short note explaining that this is a
   trial, not a change to accepted scope. You may instead leave the name blank
   and append only a note. Blank means keep; existing text is not prefilled.
4. Set **CONTEXT** to `Cole Créek inputs/analyst revised.gpkg` in the same folder
   as INPUT. Use a persistent filename, not a temporary QGIS output.
5. Set **OUTPUT** to `analyst report.html` directly in the trial folder and run
   once. Confirm your text appears in the report and earlier notes remain.
   Streams, Reaches, Survey Events and terrain associations should be unchanged.

Save the Processing log as `analyst-edit-log.txt` in the trial folder. Tell us
whether input selection, blank-field behavior, output placement and the resulting
revision were clear. No Cancel test, second run, installation or developer
preparation is assigned to you. If it fails, retain the error and any new files;
do not overwrite or delete them. Saving the context and rendering the report are
not one transaction, so a failed report can leave a context worth inspecting.

### Developer boundary for this trial

Prepare with `qualify-qgis-provider.py --revise-context --prepare-desktop-trial`
and a new output root. Reuse the already qualified `study-edit-v1/r-library` and
`plugin-final/`, identifying the frozen versions; do not silently substitute the
current workspace backend. The harness runs actual provider success/refusal
checks and direct-R equality before publishing `trial.json`.

Schema 3 identifies `r:fgrevisestudyarea`, `fg_revise_study_area.rsx`, the qualified
text provider, copied input hashes and a separate same-folder suggested context.
The launcher keeps schemas 1/2 compatible and refuses inconsistent editing
manifests. `test-study-trial-launcher.ps1` verifies valid preflight and twelve
in-memory refusal cases without launching QGIS or modifying the manifest.
This is local trial preparation, not an installer, full dependency lock or
production deployment. Return evidence belongs in the existing feature record.

## Completed trial: saved Study Area (2026-09-10)

**Completed:** the analyst reported successful execution with no confusion;
returned report tables, Processing history and input hashes were verified. No
further run is requested. Instructions below are retained for reproducibility.

This was the saved-context analyst task. Earlier network/cancellation instructions
below are historical; **do not repeat those tests**. The new tool restores saved
study context and creates the same report. It does not edit the study or approve
its data.

Save any work and close other QGIS windows. From fg-qgis-toolbox, launch:

```powershell
.\dev\scripts\start-qgis-trial.ps1 -TrialDirectory .\dev\check-output\desktop-trial-study-v1
```

Use this launcher, not an existing QGIS window: changing the input folder does
not switch the profile or its R library. This isolated profile uses the tested
development provider `4.1.0-fg-cancel1` and fgqgis 0.0.0.9002. Normal profiles and
production libraries are unchanged.

The session is a separate QGIS **desktop window**, not a Codex/browser tab. Find
it on the taskbar or with Alt+Tab. If a process exists only in Task Manager, stop
the trial and tell the developer; do not start a second copy or use your normal
shortcut. Process creation alone does not prove an interactive window opened.
The first restricted agent launch showed this failure; an unrestricted launch
of the same profile produced a main window. A launcher run from your own desktop
PowerShell is the manual alternative, after the developer has cleared only the
identified windowless trial process.

1. In **Processing → Toolbox**, search **Review Saved Study Area** and open the
   experimental FluvialGeomorph tool. Do not choose Review Stream Network.
2. For INPUT, choose `Cole Créek inputs/cole-creek-study.gpkg` inside
   `dev/check-output/desktop-trial-study-v1/`. This is the **context** file, not
   `cole-creek-network-draft.gpkg`. Keep the other files in that folder in place.
3. For OUTPUT, choose a new `analyst report.html` directly inside
   `desktop-trial-study-v1/`, then run once and open the resulting HTML.
4. Confirm the report describes **Papillion Creek → Cole Creek → R1**, with
   **2006, 2010 and 2016** Survey Events and their selected terrain grids. Missing
   Study Area AOI, unknown vertical references and provisional identities should
   still be explicit. No map layer is automatically added to QGIS.

Save the Processing log as `study-review-log.txt` in the trial folder. Tell us
whether choosing the context file and finding the restored scope was clear, and
whether the report explains what is known and what needs attention. If anything
fails, retain the error and stop; do not reinstall packages or replace files.
**No Cancel test, repeat run or developer preparation is required from you.**

Developer preparation uses `qualify-qgis-provider.py --study-context
--prepare-desktop-trial` with a new output root. It reruns the existing success,
failure, source-integrity and 19-table direct-R comparison in the actual new
profile before publishing its launch manifest. Schema 2 identifies the exact
tool/script and inventories every copied input file. The launcher still accepts
the historical schema-1 network trials. It is not a portable installer or a
complete lock of all R/QGIS dependencies.

Use `test-study-trial-launcher.ps1 -TrialDirectory <new-trial>` to check preflight
and refusal behavior without opening QGIS or altering the saved manifest. Returned
analyst evidence belongs in [the existing feature record](../features/review-study-area.md).

## Purpose

Check whether an analyst can comfortably use the first QGIS tool to reach the
existing fluvgeo report. The backend connection has passed; this trial concerns
file selection, understandable feedback, report opening and cancellation.
It is not a complete Study Area workflow or a production installation.

## Follow-up: cancellation candidate

**Completed 2026-09-09:** the returned log confirms the candidate version and
cancellation without an HTML result; the analyst reports immediate response.
No repeat is needed. The instructions below are retained for a future rerun.

The original trial is complete and its evidence is preserved. Use this section
for the **new** development candidate, not the original launcher destination below.
Developer checks pass; your remaining task is a short desktop confirmation.

Save any open work and close QGIS, then run from fg-qgis-toolbox:

```powershell
.\dev\scripts\start-qgis-trial.ps1 -TrialDirectory .\dev\check-output\desktop-trial-cancel-v1
```

This separate profile uses **R Provider 4.1.0-fg-cancel1**. It is an explicitly
modified development copy, not an official North Road release or a production
installation. No original profile is replaced.

Changing an input/output folder does not switch providers. Close QGIS and use
the launcher above; check that the run log identifies **4.1.0-fg-cancel1**.

1. Use the same experimental review tool with the copied network inside the
   **desktop-trial-cancel-v1** folder. Run once to a new HTML destination and
   confirm the normal report opens.
2. Run to a different destination and press **Cancel** while it is working.
   It should stop promptly, clearly report cancellation, and not offer that run
   as a successful HTML result. A file written just before cancellation may be
   retained, but the message must identify it as unaccepted.
3. Save the log and tell the developer whether cancellation was prompt and the
   result clear. If the run finished before the click, mark cancellation untested.

Do not run developer scripts or reinstall anything. Stop and report any cleanup
failure; do not kill unrelated R sessions. The existing report remains valid;
do not use a canceled-run file as completed output.

## Prepared local trial

Verified 2026-09-09: `dev/check-output/desktop-trial-v1/` contains a separate
QGIS profile, a copied Cole Creek network and passing real-provider/direct-R
checks. `trial.json` records exact paths and dependency hashes. The unmodified
R Provider 4.1.0 is copied into this profile only; the tested R library is reused.
Nothing was installed into the normal QGIS profile or production R library.

Close other QGIS windows, then run from the fg-qgis-toolbox repository:

```powershell
.\dev\scripts\start-qgis-trial.ps1 -TrialDirectory .\dev\check-output\desktop-trial-v1
```

The launcher checks the recorded input, script, plugin and PROJ hashes and
required paths before opening QGIS 3.44. It changes environment settings only
for its child session. `-CheckOnly` runs the checks without launching anything.
It is a local trial launcher, not a portable installer or a complete dependency
lock; changing the installation or R library requires requalification.

## Your short test

This is the analyst's part. The developer-only section below was used to prepare
your trial; you do not need to run it or learn its tooling.

1. Open **Processing → Toolbox**, search **Review Stream Network GeoPackage**,
   and open the experimental FluvialGeomorph tool. If it is absent or startup
   reports a plugin error, stop and report that message; do not reinstall anything.
2. Select `Cole Créek inputs/network draft.gpkg` inside the trial folder.
   Set OUTPUT to a new `analyst report.html` in that same trial folder and run.
3. Open the HTML result. Does the tool make it clear what was reviewed, what is
   known, and what you need to do next? Missing Study Area/terrain context is
   expected from this network-only input. No layer is automatically added to QGIS.
4. Run again with a different output name and press **Cancel** while it is running.
   Note whether it stops promptly and whether an output is left behind. If the
   run finishes before cancellation, record **not tested**, not a pass. Do not
   interpret an unexpected partial report as a successful result.

Return a short description of what worked, what was confusing, and any error or
cancellation delay. Keep the Processing log when something fails. The developer
must still check child-process cleanup and output integrity; a responsive Cancel
button alone does not establish those properties. Do not manually kill unrelated
R sessions or replace existing reports to finish this trial.

**Your part ends here.** Return the saved outputs/logs and your observations.
The developer reviews integrity, cancellation and cleanup and records the result.

## Developer-only preparation and evidence review

Preparation below is already complete for `desktop-trial-v1`. Do not rerun it
over the returned trial or replace the analyst's files.

Run [the qualification harness](../scripts/qualify-qgis-provider.py) with its
documented arguments plus `--prepare-desktop-trial` and a **new** output root.
This uses desktop-compatible QGIS settings and stages the plugin under that
isolated profile. It publishes `trial.json` only after the normal success,
failure, unchanged-source and direct-R comparison checks pass. It refuses the
dialog-only and experimental environment-removal flags in this mode.

Returned trial reviewed 2026-09-09: actual desktop execution and the first report
pass. The analyst confirmed delayed cancellation on the second run, which left
a complete report despite a failure status. See the
[review findings](../features/qgis-provider-qualification.md#analyst-trial-return-2026-09-09).
Cancellation is not qualified. Further work is developer-owned; another general
analyst trial is not needed until that behavior is addressed.

For returned trials, compare reports with the retained direct-R baseline and
verify input hashes without modifying the originals. Separate log evidence,
analyst observations, source-code explanation and unknown timing/cleanup details.
Record findings in the existing qualification record, not a new report per click.
Raw outputs stay ignored; no release gate is waived.

Profile launch options follow the official
[QGIS 3.44 configuration guide](https://docs.qgis.org/3.44/en/docs/user_manual/introduction/qgis_configuration.html#running-qgis-with-advanced-settings).
