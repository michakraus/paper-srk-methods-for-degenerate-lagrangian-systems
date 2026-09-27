using SafeTestsets

const GROUPS = isempty(ARGS) ? ["core", "slow"] : ARGS

if "core" in GROUPS
    @safetestset "Aqua" include("quality/aqua.jl")
    @safetestset "Tableau lists" include("tableau_lists.jl")
    @safetestset "Poincaré invariants" include("common.jl")
end
