# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `test/quality/aqua.jl` runs the Aqua checks. The stale-dependency check is `@test_broken`,
  issue #1: Documenter and Weave are in `[deps]`, and nothing under `src/` loads them.
- `[compat]` entries `Logging = "1"` and `Markdown = "1"`, which Aqua's compat check requires.

### Changed

- The test dependencies are in `test/Project.toml`, not in `[extras]` and `[targets]` of
  `Project.toml`. GeometricIntegrators and GeometricProblems take the root's `[compat]` bounds.
- `test/runtests.jl` holds only a `core` group of `@safetestset` files. Its two inline testsets
  moved, with the same assertions, into `test/tableau_lists.jl` (one time step with every
  tableau list) and `test/common.jl` (the Poincaré invariants of `run_poincare`).
- `test/test_scripts.jl`, which held no test and which the suite never ran, moved unchanged to
  `scripts/test_scripts.jl`.
- CI runs the shared workflow of the other experiment and package repositories. The test matrix is
  Julia `min` (the `[compat] julia` floor, 1.10) and `1` on Linux, macOS and Windows, with `pre`
  and `nightly` as advisory jobs. Coverage is uploaded from the `min` Linux job only. The `lts`
  alias gives way to `min`, and the job names change with it, so the required checks of branch
  protection can be one fixed list across all repositories.
- The documentation workflow is `Documenter.yml`, formerly `Documentation.yaml`. The weave
  pipeline is unchanged; only the action versions move to the current majors.
- Dependabot opens the `[compat]` bumps, weekly, and ignores the standard libraries. `codecov.yml`
  sets the project and patch checks to a 1 % threshold.
