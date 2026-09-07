# ADR-0001: A separate QGIS toolbox for incremental open-source migration

- Status: accepted direction from the user; toolbox implementation pending.
- Date: 2026-09-06
- Complements: FGDB ADR-0015 (shared scientific backend) and
  [ADR-0024](../../../FGDB/dev/decisions/adr-0024-geopackage-local-standard-and-archive-reconstruction.md)
  (GeoPackage and forensic archive preparation).

## Context

The user identifies the existing ArcGIS Pro toolbox as the continuing production
workflow. Developing its open-source successor inside that toolbox would couple
experimentation to production tool organization and deployment.

Verified at this decision: `fg-qgis-toolbox` exists as a separate repository on
`main`, with an initial README and license but no toolbox implementation.
fluvgeo already provides network preparation/review, GeoPackage network
persistence and Terrain Development reporting. This does not establish that
those capabilities are callable from QGIS yet.

## Decision

Use **fg-qgis-toolbox as the separate desktop implementation and user-testing
path for the new open-source workflow**. Keep FluvialGeomorph-toolbox available
for production ArcGIS Pro use. Migrate capabilities incrementally; do not make
production replacement or retirement a prerequisite for development.

The new toolbox may reorganize tool boundaries around analyst work: study
definition, terrain development, archive reconstruction, network preparation,
review and eventual FGDB handoff. It need not reproduce ArcGIS tool divisions
or menus one for one. Scientific meaning, identities, provenance and qualified
storage contracts must remain consistent across clients.

| Component | Responsibility |
| --- | --- |
| fg-qgis-toolbox | Desktop interaction, layer selection/display, tool organization, progress and explicit analyst decisions. |
| fluvgeo | Reusable scientific methods, preparation/reconstruction, validation, structured results and report components. |
| ohwm2 / Shiny | Web interaction with the same backend capabilities; automate bookkeeping and request consequential human input selectively. |
| FGDB | Governed identity reconciliation, persistence, load validation and enterprise deployment; not hidden scientific repair during loading. |
| FluvialGeomorph-toolbox | Continuing production ArcGIS Pro workflow, changed only through its own reviewed compatibility/release process. |

New functionality needed by QGIS and Shiny belongs behind reusable backend
interfaces, not solely in QGIS-specific implementations. QGIS can provide rich
desktop exploration without making QGIS a runtime dependency of Shiny. Shared
capabilities do not require identical desktop/web interaction or automatic
deployment to every client.

GeoPackage is the target local spatial-data standard under FGDB ADR-0024.
Preserve original archives; operate on identified candidates. QGIS presentation
does not bypass CRS, datatype, NoData, identity or acceptance checks, nor does a
successful display prove a scientifically faithful migration.

## Isolation and verification

Repository separation alone is insufficient when clients share an installed
backend. Development must use explicitly identified backend/dependency versions
and isolated runtime/library configurations, test data copies and output
locations. Do not upgrade production ArcGIS or Shiny environments as a side
effect of testing the new toolbox. The exact environment mechanism is still to
be selected and verified.

For each implemented capability, retain a small reviewable example, its report
and structured findings. Verify:

- the backend method independently of either user interface;
- the QGIS/backend boundary, including the values and CRS that actually cross it;
- analyst review of the resulting layers and durable report;
- relevant existing-client compatibility before promoting a shared backend;
- FGDB loading separately, only when that capability and its contracts exist.

Use synthetic cases plus retained fluvgeodata examples, expanding fixtures when
the capability requires them. Do not require the entire migration to finish
before developers or users can test a useful, bounded tool.

## First implementation proposal and unresolved choices

Start with **Review Stream Network GeoPackage**: select an existing fluvgeo
network GeoPackage, invoke the shared read/validation/report functions, show the
network and findings in QGIS, and produce a new Terrain Development HTML report.
This exercises the desktop/backend boundary without waiting for a complete
project-context storage schema. It must leave the source and acceptance history
unchanged, show incomplete context explicitly, and report failures visibly.

The first tool is a proposal, not an implemented capability or a decision that
all future tools must be read-only. Subsequent tools can expose explicit
preparation and review decisions through the same backend.

Before implementation, inspect the installed QGIS/Python/R environments and
select the packaging and QGIS-to-R execution mechanism. Define version discovery,
safe argument/path handling, cancellation, structured error/result handling and
GeoPackage ownership while processes access files. Those integration choices,
supported versions and deployment procedures are **unknown/unselected**, not
settled by this migration decision.

## Consequences

This provides one incremental migration path for open-source desktop tooling,
full backend capability coverage in Shiny, and workflow-driven FGDB design and
deployment. It does not claim any of those outcomes is complete. Production
ArcGIS tools, deployed Shiny applications, enterprise services and archives are
unchanged by recording this decision.
