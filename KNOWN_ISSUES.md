# Known issues

## KI-1 · test: the `integrates` guard accepts a `DomainError` from building a tableau

Kind: test gap. `test/tableau_lists.jl:30–36` tolerates every `DomainError`, including one thrown
while the tableau is built, not only one thrown while a valid tableau integrates. The mutant
`VPRKRadauIIA(2),` → `VPRKRadauIIA(-2),` in `src/tableau_lists.jl` survives: all 90 tests pass.
The guard was already there before the tests moved out of `runtests.jl`, so the move keeps it.

## KI-2 · docs: CHANGELOG says the moved testsets are unchanged

Kind: docs. The `[Unreleased]` entry says the two inline testsets "moved unchanged". The formatter
rewrapped `test/common.jl` and `test/tableau_lists.jl`, and `test/common.jl` uses the `SRK` alias
in place of `using SrkMethodsForDegenerateLagrangianSystems`. The assertions are the same. Evidence:
`git diff origin/main...HEAD -- test/`.
