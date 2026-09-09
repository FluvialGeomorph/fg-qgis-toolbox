# Draft: cancellation waits for R console output and can return successful HTML

Local contribution draft, reviewed 2026-09-09. **Not submitted.** Related to
[issue #13](https://github.com/north-road/qgis-processing-r/issues/13), which
reports failed-script outputs appearing in the results viewer. The cancellation
reproducer below provides a separate, testable execution failure; maintainers
may prefer it attached to that issue rather than opened separately.

## Problem and tested environment

With Processing R Provider 4.1.0 on Windows, cancellation during a quiet R
operation is delayed until console output resumes. In our automated provider
test, cancellation was requested 0.3 seconds after `READY`; the call returned
3.765 seconds later, reported success and returned an HTML output.

Tested: QGIS 3.44.14 LTR, R 4.6.0, Windows. The actual desktop report workflow
also showed delayed cancellation and a generated report after QGIS reported
failure. We have not tested Linux, macOS or QGIS 4.

The two relevant source files in upstream commit
[`e4f83a1`](https://github.com/north-road/qgis-processing-r/commit/e4f83a13109eb9dd7989cbfd38a37ab16daa0788)
are byte-identical to those in our tested 4.1.0 plugin. This is a source
comparison, not a separate execution of the complete upstream checkout.

## Minimal reproduction

Save this as `cancel_probe.rsx` in a disposable R-script folder configured in an
isolated QGIS profile using the **unmodified** provider. No spatial data or
additional R packages are needed.

```r
##cancel_probe=name
##dont_load_any_packages
##OUTPUT=output html
cat("READY\n"); flush(stdout()); Sys.sleep(4); writeLines("<html>complete</html>", OUTPUT)
```

Run it with a new HTML destination and press Cancel promptly after `READY`.
The automated test uses this same script and requests cancellation after 0.3
seconds, avoiding manual timing ambiguity. For a longer manual interaction
window, increase the sleep; that variation is not the measured four-second case.

Expected: cancellation is observed while R is quiet, the run stops promptly,
and no successful output is returned. Files already written need not be deleted,
but must not be advertised as completed results of a canceled run.

Observed in the automated test: success was returned and the HTML existed.
The desktop's failed status alone therefore does not establish that R stopped
or that its outputs were withheld.

## Source diagnosis and bounded prototype

In
[`execute_r_algorithm()`](https://github.com/north-road/qgis-processing-r/blob/e4f83a13109eb9dd7989cbfd38a37ab16daa0788/processing_r/processing/utils.py),
the cancellation check follows a blocking `stdout.readline()`. Termination
targets the immediate process, and there is no explicit nonzero-exit check
before the algorithm attempts to read its output-values file. In
[`processAlgorithm()`](https://github.com/north-road/qgis-processing-r/blob/e4f83a13109eb9dd7989cbfd38a37ab16daa0788/processing_r/processing/algorithm.py),
successful output return also needs a cancellation boundary check.

A development-only Windows prototype decouples console reading from cancellation
polling, stops the owned process tree, checks exit status, and suppresses accepted
results on observed cancellation. Eight actual-provider/R regression cases pass:
quiet cancellation, normal success, nonzero exit, pre-cancellation, cancellation
after file creation, cancellation after output parsing, large console output,
and cancellation with a live child R process. Running cancellation cases returned
in 0.141–0.188 seconds. A separate analyst desktop confirmation reported immediate
cancellation with no requested HTML created; the desktop log does not measure
click-to-stop latency.

The prototype is **not a cross-platform patch ready for merging**. It force-stops
the owned Windows process tree, retains files already written, and cannot promise
R cleanup hooks, detached-child containment or cancellation after results have
already been handed to QGIS. OS permission denial is a cleanup failure, not a
successful cancellation. The local test harness is Windows-specific too.

Would you prefer an extension to issue #13 or a separate cancellation issue?
Before preparing a PR, which cross-platform subprocess/cancellation approach and
supported QGIS versions should a fix target? We can supply the synthetic
regression cases without project data; Windows process-tree behavior needs
coverage alongside the existing Linux-based test workflow.
