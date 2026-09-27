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
  moved unchanged into `test/tableau_lists.jl` (one time step with every tableau list) and
  `test/common.jl` (the Poincaré invariants of `run_poincare`).
- `test/test_scripts.jl`, which held no test and which the suite never ran, moved unchanged to
  `scripts/test_scripts.jl`.
