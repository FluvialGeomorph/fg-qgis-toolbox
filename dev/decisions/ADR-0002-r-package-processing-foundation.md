# ADR-0002: R package foundation for the FluvialGeomorph QGIS tools

- Status: working architectural decisions accepted by the user; runtime
  qualification and deployment pending.
- Date: 2026-09-07
- Refines: ADR-0001's previously unresolved packaging and QGIS-to-R choices.

## Context

The open-source migration needs familiar package documentation, testing and
versioned distribution before exposing functionality. It must not duplicate
fluvgeo's science or disturb the production ArcGIS toolbox. The user explicitly
selected reproducibleai, usethis, the North Road R Provider, inline-help `.rsx`
wrappers, and testthis with fluvgeodata.

## Decision

1. Manage this repository as the R package **fgqgis**, scaffolded with usethis.
   Keep the repository name `fg-qgis-toolbox`. Follow fluvgeo's author/maintainer
   metadata as directed; preserve this repository's existing CC0 license.
2. Use reproducibleai's `base` and `r-package` profiles for durable development
   context. Record decisions and operational knowledge in the existing routes,
   without creating a second governance system or requiring a checkpoint per task.
3. Use the existing **North Road Processing R Provider**. “FluvialGeomorph” is
   our algorithm group within its **R** provider, not a new Python provider.
4. Ship user-facing `.rsx` files under `inst/rscripts/`, with inline help as
   the single tool-help source. Keep scientific processing, validation and report
   construction in fluvgeo. Package R functions may support asset discovery and
   adapter concerns, not fork the backend's methods.
5. Use testthis for explicit wrapper-suite creation/execution and testthat for
   assertions and standard package tests. Retained fluvgeodata exercises real
   inputs; use synthetic cases for controlled failures. Test only disposable
   output copies, preserving archives.
6. Complete package/context/test foundations before deployment. Installation of
   this R package must never configure QGIS or install/upgrade other packages.
   Qualify actual QGIS execution separately before exposing the first algorithm.

## Consequences and evidence limits

Verified in upstream documentation/source: `.rsx` metadata, inline help, and
the provider/group distinction support this design. The package name and layout
are implementation choices under the user's direction. Package tests cannot
establish provider parsing, subprocess behavior, cancellation or GUI usability.

The foundation contains one **test-only** flowline-check wrapper, not a released
algorithm. fluvgeo is presently a suggested test dependency; declare it as a
runtime dependency with a qualified minimum version when the first real wrapper
ships. Do not infer dependency compatibility from sibling development versions.

Supported QGIS/R Provider/R/backend versions, dependency distribution, promotion
and rollback, process cancellation, file locking, and complete CRS/type fidelity
remain unqualified. See the [boundary review](../architecture/qgis-r-boundary.md)
and [development workflow](../workflows/qgis-package-development.md).
