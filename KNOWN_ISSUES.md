# Known issues

## KI-1 · test: the `integrates` guard accepts a `DomainError` from building a tableau

Kind: test gap. `test/tableau_lists.jl:30–36` tolerates every `DomainError`, including one thrown
while the tableau is built, not only one thrown while a valid tableau integrates. The mutant
`VPRKRadauIIA(2),` → `VPRKRadauIIA(-2),` in `src/tableau_lists.jl` survives: all 90 tests pass.
