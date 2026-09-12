# Withdrawn experiment: terrain coverage percentages

Status: withdrawn by the analyst, 2026-09-11. The experimental API, QGIS tool,
report chart/percentages, tests and dedicated qualification scripts were removed
before deployment. Prior ignored outputs under `dev/check-output/terrain-coverage-v1/`
remain historical experiment evidence, not current reports or accepted criteria.

## Domain decision

NoData is routinely and intentionally introduced to mask terrain outside the
chosen area of interest, reduce processing and reduce storage. It is not evidence
that required elevation data are missing. The fraction of a raster rectangle
containing finite cells depends largely on stream orientation and rectangle
layout; it does not answer a useful study-definition or quality question.
An extent-derived Reach rectangle does not improve that metric's meaning.

Do not reintroduce these percentages, automatic completeness thresholds, warnings
about intentional masks, or demands to fill NoData. File absence, corruption,
CRS conflicts and unsupported spatial operations remain legitimate independent
checks. A future analysis may require a specifically defined AOI and suitability
review, but that is not generic raster-rectangle occupancy.

The experiment also caught an undefined-weight aggregation defect. Correct
arithmetic and extensive tests did not establish that the metric was useful.
Consult geographic judgment before adding another terrain quality measure.

Next: [Record Terrain Metadata](record-terrain-metadata.md), which records
supported vertical assertions without guessing values or altering terrain.
