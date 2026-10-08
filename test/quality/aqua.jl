using Aqua
using SrkMethodsForDegenerateLagrangianSystems
import SrkMethodsForDegenerateLagrangianSystems as SRK
using Test

Aqua.test_all(
    SrkMethodsForDegenerateLagrangianSystems;
    stale_deps = false,  # issue #1: run as @test_broken below
    # CairoMakie is a direct dependency, so on Julia 1.11 the check's `Pkg.precompile` also builds
    # the Makie extensions of PoincareInvariants and GeometricProblems after the package loads.
    # On 1.11.9 the check fails with `tmax = 30` after 43-47 s and passes with `tmax = 300` after
    # 59-174 s.
    persistent_tasks = (; tmax = 300)
)

# `test_stale_deps` takes no `broken` keyword, so its check is run here directly.
# issue #1: Documenter and Weave are in [deps] of Project.toml and nothing under src/ loads them
@testset "Stale dependencies" begin
    @test_broken isempty(Aqua.find_stale_deps(Base.PkgId(SRK)))  # issue #1
end
