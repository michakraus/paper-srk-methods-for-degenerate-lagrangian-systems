#
# Weave the documentation pages of one problem into `docs/src/<problem>/`.
#
#   julia --project=.. weave.jl <problem> [<page> ...]
#
# With no page arguments all method families of `<problem>` are woven; naming individual
# pages allows the CI workflow to build them as parallel matrix jobs.
#
# Examples:
#
#   julia --project=.. weave.jl massless-charged-particle-singular
#   julia --project=.. weave.jl massless-charged-particle-singular srk vprk-radau
#

using GeometricIntegrators
using Weave

import SrkMethodsForDegenerateLagrangianSystems as SRK


# problem name (in `src/`, `weave/` and `docs/src/`) → module defined by `src/<problem>.jl`
const PROBLEMS = (
    "lotka-volterra-2d-singular"         => :LotkaVolterra2dSingularSRK,
    "lotka-volterra-2d-symmetric"        => :LotkaVolterra2dSymmetricSRK,
    "massless-charged-particle-singular" => :MasslessChargedParticleSingularSRK,
    "massless-charged-particle-standard" => :MasslessChargedParticleStandardSRK,
)

# page name → `weave/<problem>-<page>.jmd`
const PAGES = ("vprk-gauss", "vprk-lobatto-ab", "vprk-lobatto-ba", "vprk-radau", "firk", "srk")

source_path(problem, page) = joinpath(@__DIR__, "..", "weave", "$(problem)-$(page).jmd")


# Returns `(problem, module name, pages)` for the command line arguments.
function parse_arguments(args)
    isempty(args) && error("usage: julia --project=.. weave.jl <problem> [<page> ...]\n" *
                           "problems: " * join(first.(PROBLEMS), ", ") * "\n" *
                           "pages: " * join(PAGES, ", "))

    problem = args[1]
    pages   = length(args) > 1 ? args[2:end] : collect(PAGES)

    i = findfirst(p -> first(p) == problem, PROBLEMS)
    i === nothing && error("unknown problem \"$problem\"; expected one of " *
                           join(first.(PROBLEMS), ", "))

    for page in pages
        page in PAGES || error("unknown page \"$page\"; expected one of " * join(PAGES, ", "))
        isfile(source_path(problem, page)) || error("no such document: $(source_path(problem, page))")
    end

    (problem, last(PROBLEMS[i]), pages)
end

const problem, modname, pages = parse_arguments(ARGS)


Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include(joinpath(@__DIR__, "../src/$(problem).jl"))

# resolved at top level, i.e. after the world of the `include` above
const mod = getfield(Main, modname)

# Silence the line search of the diverging methods and the repetitive tick warnings of the
# plotting stack, which would otherwise bury the results in the build log; see
# `quiet_solver_warnings!` in src/common.jl. (In the SPARK companion package the same call
# reads `mod.quiet_solver_warnings!()`, because its problem modules include `common.jl`
# themselves instead of importing the package module.)
SRK.quiet_solver_warnings!()

for page in pages
    weave(source_path(problem, page),
             out_path = "src/$(problem)",
             doctype = "github",
             mod = mod)
end
