# R Provider cancellation candidate

Development-only adaptation of North Road R Provider 4.1.0. It is not a new
provider, an fgqgis runtime dependency, or an installed-plugin hotfix. The user
authorized the next cancellation development step after the analyst trial.
Production adoption/upstream contribution remains a separate decision.

## Behavior

- Poll the owned R process every 50 ms independently of its console output.
  Console bytes go to a run-owned temporary log with a separate reader position,
  avoiding blocking `readline()` and pipe-capacity deadlocks.
- On Windows, stop the still-owned process PID and its descendants with the
  system `taskkill /PID ... /T /F`, then wait for the parent. Never terminate by
  process name or target an existing user's R/QGIS session.
- Return no successful results on observed cancellation, including before start,
  after R execution and after output parsing. Report a nonzero R exit directly,
  before trying to read the missing output-values file.
- Retain files already written and explicitly mark the run unsuccessful. Do not
  delete, overwrite or silently accept outputs to hide a canceled run. Forcefully
  terminated R cleanup hooks are not guaranteed to execute; temporary artifacts
  may remain under QGIS's run directory.

This candidate supports Windows only. Process-tree termination requires OS
permission; denial is a cleanup failure, not successful cancellation. Detached
children/reparenting, hostile processes and cancellation arriving after the
provider has handed results to QGIS are outside the demonstrated guarantee.
This is not transactional rollback or comprehensive job containment.

## Reproduce without modifying a profile

1. Run `dev/scripts/stage-cancellation-candidate.py` with the upstream plugin
   parent and a **new** destination under this repo's `dev/check-output/`.
   It verifies the two edited upstream files against pinned SHA-256 values,
   copies them, applies the bounded changes and adds `fg_cancel.py`.
2. Run `dev/scripts/test-provider-cancellation.py` with explicit `--osgeo`,
   `--plugin-parent`, `--r-home`, new `--output-root` and `--candidate`.
   Omit `--candidate` with upstream 4.1.0 to reproduce the blocking baseline.
3. Run the ordinary `qualify-qgis-provider.py` against the candidate to verify
   the real Cole Creek report, invalid-input/overwrite failures and direct-R
   agreement. `--prepare-desktop-trial` stages it in another isolated profile.

The candidate identifies itself as **4.1.0-fg-cancel1** and includes the upstream
source/license headers. `fg_cancel.py` is GPL-3.0-or-later for this provider
adaptation; the containing R package's license and distributed assets are not
changed. No contribution is automatically sent upstream.

## Evidence

The retained baseline in `dev/check-output/cancel-baseline-v1/` took 3.765 seconds
to return after cancellation during a four-second quiet R operation and still
returned success plus HTML. The candidate's permitted tests are retained under
`dev/check-output/cancel-candidate-v1/`; a sandbox-restricted attempt reported
cleanup failure and is not qualification evidence. Tests require an explicit
cancellation result, not merely a quick return.

The complete permitted run (`tests-complete/`) passes eight cases, including a
real child R process whose retained Windows handle signals exit. Cancellation
returned in 0.141–0.188 seconds for the running cases. The real Cole Creek suite
also passes with the candidate in `dev/check-output/desktop-trial-cancel-v1/`,
including direct-R agreement and unchanged source/overwrite checks.

The source of the delay and architectural scope are recorded in
[the qualification record](../../features/qgis-provider-qualification.md).
The corrected approach follows the documented subprocess and process-tree
semantics in [Python](https://docs.python.org/3/library/subprocess.html) and
[Microsoft](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/taskkill).
