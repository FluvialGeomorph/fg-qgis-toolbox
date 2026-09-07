# Working `.rsx` wrapper contract

- One user-facing algorithm per `inst/rscripts/<stable_id>.rsx`.
- Use a stable lowercase `fg_`-prefixed name, a separate human-facing display
  name and `##FluvialGeomorph=group`. Avoid renaming IDs after publication.
- Declare every parameter/output through provider metadata. Prefer `INPUT` and
  `OUTPUT` for primary parameters in new tools; additional names describe roles.
- Document each parameter/output inline with `#' KEY: text`, plus `ALG_DESC`
  and `ALG_VERSION`. Explain units, required CRS/geometry, source modification,
  output ownership, missing-context limitations and consequential analyst input.
- Delegate scientific decisions to explicit `fluvgeo::` calls. Adapter code may
  validate transport, map parameters and expose results, not reimplement science.
- No interactive prompts, hard-coded workstation paths, global working-directory
  changes, runtime package installation or hidden acceptance/repair.
- Write only declared, user-selected or test-owned outputs. Preserve archives;
  fail visibly on invalid inputs and unsafe destinations. No blanket error
  suppression, silent reprojection, or implied FGDB readiness from file creation.
- Keep the initial body ordinary R; metadata/help are comments. Provider-specific
  executable syntax such as `>` needs actual provider tests before adoption.

`tests/testthat/helper-rsx.R` checks a subset of these conventions. It is not a
complete parser or proof of architectural compliance; review handles ownership
and scientific meaning. Tests must exercise actual script bodies. Test-only
scripts stay under `tests/testthat/fixtures/`, never `inst/rscripts/`.
