using Aqua
using SrkMethodsForDegenerateLagrangianSystems
import SrkMethodsForDegenerateLagrangianSystems as SRK
using Test

Aqua.test_all(
    SrkMethodsForDegenerateLagrangianSystems;
    stale_deps = false,  # issue #1: run as @test_broken below
)

# `test_stale_deps` takes no `broken` keyword, so its check is run here directly.
# issue #1: Documenter and Weave are in [deps] of Project.toml and nothing under src/ loads them
@testset "Stale dependencies" begin
    @test_broken isempty(Aqua.find_stale_deps(Base.PkgId(SRK)))  # issue #1
end
