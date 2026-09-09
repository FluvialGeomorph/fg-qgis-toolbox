# Development context

This directory contains durable, repository-owned context for human and agentic development. `AGENTS.md` routes tasks here; the artifacts below hold the detail.

- `goals/`: scope, outcomes, and success criteria
- `architecture/`: system structure and ownership boundaries
- `decisions/`: accepted architectural decision records
- `governance/`: artifact authority and lifecycle rules
- `workflows/`: repeatable procedures
- `schemas/`: exact structural contracts
- `features/`: cohesive capability specifications
- `checkpoints/`: concise resumable state
- `scripts/`: supporting development automation

Chat transcripts and generated output are not canonical project context.

## Current project routes

- [Start here: purpose, established progress and next milestone](goals/project-plan.md)
- [What the QGIS/R experiment established, and its limits](features/qgis-provider-qualification.md)
- [Analyst trial guide and developer-owned return review](workflows/qgis-desktop-trial.md)
- [How this fits the wider migration](../../FG-architecture/dev/architecture/system-overview.md#open-source-migration-why-the-pieces-fit-together)
- [R package/provider decisions](decisions/ADR-0002-r-package-processing-foundation.md)
- [QGIS boundary and upstream compliance review](architecture/qgis-r-boundary.md)
- [Wrapper authoring contract](schemas/rsx-wrapper-contract.md)
- [Package and wrapper testing](workflows/qgis-package-development.md)
