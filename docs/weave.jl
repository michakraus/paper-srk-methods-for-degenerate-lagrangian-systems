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


# problem name (in `src/`, `weave/` and `docs/src/`) → module defined by `src/<problem>.jl`
const PROBLEMS = (
    "lotka-volterra-2d-singular"         => :LotkaVolterra2dSingularSRK,
    "lotka-volterra-2d-symmetric"        => :LotkaVolterra2dSymmetricSRK,
    "massless-charged-particle-singular" => :MasslessChargedParticleSingularSRK,
    "massless-charged-particle-standard" => :MasslessChargedParticleStandardSRK,
)

# page name → `weave/<problem>-<page>.jmd`
const PAGES = ("vprk-gauss", "vprk-lobatto-ab", "vprk-lobatto-ba", "vprk-radau", "firk", "srk")


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
    end

    (problem, last(PROBLEMS[i]), pages)
end

const problem, modname, pages = parse_arguments(ARGS)


Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include(joinpath(@__DIR__, "../src/$(problem).jl"))

# resolved at top level, i.e. after the world of the `include` above
const mod = getfield(Main, modname)

for page in pages
    weave("../weave/$(problem)-$(page).jmd",
             out_path = "src/$(problem)",
             doctype = "github",
             mod = mod)
end
