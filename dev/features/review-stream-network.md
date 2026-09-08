# Review Stream Network GeoPackage

Status: experimental implementation; **not qualified for QGIS deployment**.
Date: 2026-09-08. Implements the first milestone in the project plan and ADR-0002,
without changing the scientific or persistence ownership boundaries.

## Contract

`inst/rscripts/fg_review_stream_network.rsx` declares stable name
`fg_review_stream_network`, group FluvialGeomorph, one `INPUT=file gpkg` and one
`OUTPUT=output html`. It calls only the fluvgeo summary and report functions.
The summary reads and freshly validates the full `FLUVGEO_NETWORK_GPKG_1`
bundle; an arbitrary single-layer GeoPackage is not accepted as that bundle.
The report destination must be new, `.html`, and in an existing directory on
a local filesystem supporting hard links. Rendering and safe publication belong
to fluvgeo; the wrapper performs no separate geometry or metadata conversion.

The output describes this network and its missing context. It does not recover
the demo's Study Area boundary, Reach/Event inventory, manifest links or DEMs
from the network alone. Neither draft findings nor output creation constitute
repair, review approval, acceptance, full study completeness or FGDB readiness.
No source is modified. No package installation, profile editing, reprojection,
new identity assignment or automatic layer loading is performed by the script.
Use a persistent output path to keep a durable record.

The inline help is the authoritative tool help. Metadata follows the upstream
[script syntax](https://north-road.github.io/qgis-processing-r/script-syntax/);
the upstream [output parser](https://github.com/north-road/qgis-processing-r/blob/master/processing_r/processing/outputs.py)
maps `output html` to an HTML-filtered file destination. This source review is
not evidence that a particular installed provider executes this script correctly.
`dont_load_any_packages` disables automatic spatial transport packages; backend
namespaced calls load their own dependencies. No provider-only executable syntax
or wrapper-side scientific decision is introduced.

## Verification scope

The explicit testthis suite builds a disposable draft bundle from the retained
Cole Creek 2006 `stream_network`. The 2010 archive does not contain that layer;
the existing companion flowline suite exercises all three events (2006/2010/2016)
without inventing missing networks. Test UUIDs and
0.01 m tolerance are fixture scaffolding, not approved project configuration.
It executes the actual packaged script and compares substantive summary fields
and fresh validation result against direct fluvgeo calls, renders offline HTML,
checks overwrite/source-path refusal, missing inputs and non-bundle GeoPackages,
and hashes both the input bundles and original archive files before/after.
Fresh run IDs/timestamps are not expected to match. Fast tests cover metadata,
help and missing/incompatible backend failures.

Paths containing spaces and non-ASCII text are exercised with a Windows UTF-8
character locale. An initial run forced to the C locale failed in the backend's
base-R `tempfile()` before wrapper execution: it could not translate the Unicode
path. The test now selects UTF-8 locally and restores the locale afterwards.
This is a runtime qualification constraint, not a silently fixed provider setting
or a claim of Unicode support in every locale.

Verified on 2026-09-08 with R 4.6.0, sibling fluvgeo `12d3c9b` and
fluvgeodata `f6bc262`: 27 fast assertions and 66 explicit testthis assertions
passed, with no failures, test warnings or skips. Source build and
`R CMD check --no-manual --no-vignettes` completed with **Status: OK**.
The check used `_R_CHECK_FORCE_SUGGESTS_=false`; fluvgeo, fluvgeodata and testthis
were absent from the check library and exercised separately by the workspace
suite. Repository-index access and the workstation's `du` utility emitted
environment diagnostics; testthat also reports being built under R 4.6.1.
Logs/build are ignored under `dev/check-output/network-review-v1/`.
Strict reproducibleai context validation passed with the two existing
seeded-content warnings. No installed-version compatibility matrix is implied.

## Remaining qualification gate

Read-only discovery found no QGIS executable on PATH, no QGIS directory under
Program Files, Program Files (x86), LocalAppData/Programs or the drive root, no
OSGeo directory at the drive root, no matching standard uninstall entry, and no
standard AppData QGIS3 profiles. This does **not** exclude a portable/custom
installation elsewhere. No runtime or plugin was downloaded or configured.

Once a runtime is supplied, follow the full
[boundary qualification checklist](../architecture/qgis-r-boundary.md). In an
explicitly isolated profile/library, verify registration, inline help, file
parameter transport, persistent and temporary HTML outputs, direct-R agreement,
batch execution, invalid input, missing dependencies/Pandoc, cancellation,
partial outputs, locking, Unicode paths/locale and unchanged sources. Capture
the actual QGIS/provider/R/backend versions and reviewed results.

The experimental package keeps fluvgeo in Suggests with an explicit runtime API
guard. This is **not** the release dependency contract: before deployment, qualify
an installed backend version and declare the runtime dependency/minimum version
required by ADR-0002. Sibling development source tests cannot establish that
version bound. No production ArcGIS or Shiny environment is changed.
