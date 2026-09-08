# Develop and test QGIS wrappers

Read the workspace workstation notes before invoking R on Windows. Commands
below are R expressions from the repository root unless shown as script paths.

## Foundation and dependencies

The foundation was generated using `dev/scripts/bootstrap-foundation.R`
(usethis + reproducibleai), then `configure-foundation.R` (testthis suite and
package metadata). These are foundation-maintenance scripts, not installers.
The latter deliberately copies the approved sibling fluvgeo author metadata.
Do not rerun generators to overwrite maintained context.

Install development dependencies into a chosen isolated library. The current
workstation uses ignored `dev/local-library/` for testthis 1.1.1; this directory
is neither committed nor packaged. No test command downloads dependencies.
Workspace tests explicitly load sibling source packages; release qualification
must use identified installed versions instead.

## Normal edit/test loop

1. Put science in fluvgeo first. Add a small adapter in `inst/rscripts/`, following
   the [wrapper contract](../schemas/rsx-wrapper-contract.md).
2. Add fast contract tests plus a test in `tests/testthat/wrappers/` comparing
   the actual script with a direct fluvgeo call. Include invalid input and source
   preservation. Use fluvgeodata as evidence, never silently skip its absence in
   this explicit suite. Add synthetic edge cases where retained data is inadequate.
3. Run `testthat::test_local(".")` for fast tests. Run
   `Rscript --vanilla dev/scripts/test-wrappers.R --workspace` for sibling-source
   integration, or omit `--workspace` to use installed backend/data packages.
   The latter requires all test dependencies already installed.
4. Run `roxygen2::roxygenise(".")` when package API documentation changes.
   Run `R CMD build` and `R CMD check` on the resulting tarball. The explicit
   testthis subdirectory suite is additional; package check does not run it.
5. Validate context with `reproducibleai::validate_agentic_context(".", strict=TRUE)`.
   Review changes and update only the affected durable records.

testthis creates/runs test subdirectories on top of testthat, not a separate
assertion engine. [Upstream API](https://s-fleck.github.io/testthis/reference/test_subdir.html).
Installed 1.1.1 attempts an RStudio save even when running headlessly. Our runner
temporarily replaces only that save call with a no-op outside RStudio, using a
scoped testthat binding. It restores the binding afterwards, sources shared test
helpers, and still invokes `testthis::test_subdir("wrappers")`. This compatibility
workaround changes no installed package files. Revisit it when testthis changes.

## Two distinct verification levels

The test fixture uses Cole Creek 2006/2010/2016 flowlines, makes temporary
GeoPackages, checks CRS/coordinates/attributes, compares fluvgeo validation,
propagates malformed-input errors, and hashes original archive files. It does
**not** qualify whole-archive conversion, terrain development or FGDB loading.

The experimental network-review test additionally uses the retained 2006
network, compares direct-R summaries, renders HTML and tests source/overwrite
safety. It requires Pandoc (see workstation routing) and temporarily selects a
Windows UTF-8 character locale for Unicode paths. See its
[verification record](../features/review-stream-network.md).

Sourcing an `.rsx` with supplied R objects tests adapter behavior only. It does
not test the provider parser, transport or UI. After package tests, perform the
separate QGIS qualification in the [boundary review](../architecture/qgis-r-boundary.md).
Record runtime versions and reviewed outputs before offering an installation
procedure. Never configure the provider to scan tests or the repository root.

## Foundation verification (2026-09-07)

- R 4.6.0; usethis 3.2.1, testthis 1.1.1, testthat 3.3.2, sf 1.1.2,
  roxygen2 8.1.0. reproducibleai source at `9eed6da` scaffolded both profiles.
- 15 fast assertions and 36 explicit wrapper assertions passed, without skips
  or test failures. Wrapper tests used sibling fluvgeo (`6e4300b` plus existing
  working changes) and fluvgeodata (`f6bc262`), not installed release versions.
- Source package build and `R CMD check --no-manual --no-vignettes` succeeded.
  Check used `_R_CHECK_FORCE_SUGGESTS_=false`: fluvgeo/fluvgeodata were not
  installed in its library. Their integration was tested separately above.
  Network index lookups and the workstation's `du` command emitted diagnostics;
  the completed check reported `Status: OK`.
- Strict reproducibleai validation passed. Two expected seeded-content warnings
  identify our maintained additions to `dev/README.md` and the R workflow; preserve
  those changes during future scaffold upgrades.
- No QGIS execution, profile changes, production library changes or deployment.
  Generated packages, raw logs and the local testthis installation are ignored.
