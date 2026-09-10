# Analyst desktop trials

## Current trial: saved Study Area (2026-09-10)

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
