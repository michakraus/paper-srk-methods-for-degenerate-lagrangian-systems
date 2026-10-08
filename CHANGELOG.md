# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `test/quality/aqua.jl` runs the Aqua checks. The stale-dependency check is `@test_broken`,
  issue #1: Documenter and Weave are in `[deps]`, and nothing under `src/` loads them.
- `[compat]` entries `Logging = "1"` and `Markdown = "1"`, which Aqua's compat check requires.
- Dependabot opens the `[compat]` bumps, weekly, for the root `Project.toml` only, and ignores the
  standard libraries. The bounds in `test/Project.toml` are not bumped.
- `codecov.yml` sets the project and patch checks to a 1 % threshold.
- An advisory `Downgrade - ubuntu-latest` job tests the `[compat]` lower bounds. It resolves each
  direct dependency of the root `Project.toml` to its lower bound on the lowest Julia and runs the
  suite there. It is not a required check.

### Changed

- The floors rise to Julia 1.11, GeometricIntegrators 0.18.6, GeometricIntegratorsBase 0.6.9,
  GeometricProblems 0.9.1, PoincareInvariants 0.5.1 and SimpleSolvers 0.14.1, because
  GeometricBase 0.15 declares its stubs public and requires Julia 1.11.
- The Weave floor rises to `"0.10.11"`: up to 0.10.10 it caps Highlights at 0.4, and so
  DocStringExtensions at 0.8, while GeometricProblems 0.9.1 needs DocStringExtensions 0.9 through
  EulerLagrange 0.5.2 and Symbolics 7. Compat-only; no behaviour changes.
- The test dependencies are in `test/Project.toml`, not in `[extras]` and `[targets]` of
  `Project.toml`. GeometricIntegrators and GeometricProblems, which are dependencies of the root,
  have no `[compat]` entry in `test/Project.toml`, so the root's bounds apply.
- `test/runtests.jl` holds only a `core` group of `@safetestset` files. Its two inline testsets
  moved, with the same assertions, into `test/tableau_lists.jl` (one time step with every
  tableau list) and `test/common.jl` (the Poincaré invariants of `run_poincare`).
- `test/test_scripts.jl`, which held no test and which the suite never ran, moved unchanged to
  `scripts/test_scripts.jl`.
- CI runs the shared workflow of the other experiment and package repositories. The test matrix is
  Julia `min` (the `[compat] julia` floor, 1.11) and `1` on Linux, macOS and Windows, with `pre`
  and `nightly` as advisory jobs. Coverage is uploaded from the `1` Linux job only, and a test job
  saves the Julia cache only when it succeeds. The `lts` alias gives way to `min`, and the job names change with it, so the required checks of branch
  protection can be one fixed list across all repositories.
- CI runs on a push to `main` or `master`, on tags, on pull requests and on manual dispatch. It ran
  on every push to any branch, so a push to a topic branch without a pull request runs no CI.
- A new `Doctests - ubuntu-latest` job skips itself here, because the repository has no
  `docs/Project.toml`.
- The documentation workflow is `Documenter.yml`, formerly `Documentation.yaml`. The weave
  pipeline is unchanged; only the action versions move to the current majors. The comment in
  `docs/Makefile` names the new file.
