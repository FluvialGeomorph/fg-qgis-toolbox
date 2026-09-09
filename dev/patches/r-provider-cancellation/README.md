# R Provider cancellation candidate

Development-only adaptation of North Road R Provider 4.1.0. It is not a new
provider, an fgqgis runtime dependency, or an installed-plugin hotfix. The user
authorized the next cancellation development step after the analyst trial.
Production adoption/upstream contribution remains a separate decision.

## Maintenance review (2026-09-09)

**Verified:** a live, read-only GitHub API review found upstream `master` at
[`e4f83a1`](https://github.com/north-road/qgis-processing-r/commit/e4f83a13109eb9dd7989cbfd38a37ab16daa0788)
(2024-01-15). Its `utils.py` and `algorithm.py` SHA-256 values exactly match the
4.1.0 files pinned by our staging script. The cancellation defect therefore
remains in the inspected source; we did not execute the full upstream checkout.
[Issue #13](https://github.com/north-road/qgis-processing-r/issues/13) is open and
describes failed-script outputs appearing in the results viewer. A title/body
search for `cancel` returned no issues or PRs; this is not proof that no related
discussion exists. Neither open PR changes the execution files:
[#53](https://github.com/north-road/qgis-processing-r/pull/53) concerns parameter
editing, and [#136](https://github.com/north-road/qgis-processing-r/pull/136)
concerns QGIS 4/Qt6 migration. The inspected
[test workflow](https://github.com/north-road/qgis-processing-r/blob/e4f83a13109eb9dd7989cbfd38a37ab16daa0788/.github/workflows/test_plugin.yaml)
runs pytest in Linux QGIS containers; it does not establish Windows behavior.

**Proposed path:** upstream-first, with a narrowly maintained local development
candidate while normal Study Area work resumes. The
[contribution draft](upstream-issue-draft.md) contains a data-free reproducer and
the measured results. Review it before publishing; no issue, comment, PR, fork
or production installation was created. Ask maintainers where this belongs and
agree on cross-platform behavior before turning the Windows prototype into a PR.
Maintainer acceptance, timing and the eventual supported-version target are
**unknown**. Commit age alone is not evidence that the project is abandoned.

Until a separate adoption decision, fgqgis development owns only this bounded
candidate and its test harness, not a replacement provider. Keep it in the
isolated profile with its distinct version; do not install it automatically with
the R package or overlay a user's normal plugin. On any upstream change, staging
must fail on differing source hashes rather than silently reapplying the patch.
Review changes and repeat cancellation/exit tests plus real-report/direct-R
agreement before qualifying a new candidate. No automatic upgrade is authorized.

Retire the candidate when an official release passes those checks on the intended
Windows/QGIS/R combination and one desktop cancellation confirmation. If upstream
cannot accommodate a fix, bring the explicit choice of a maintained fork or an
alternative execution boundary back for review before production deployment.
Continued read-only workflow development does not depend on an upstream response.

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
