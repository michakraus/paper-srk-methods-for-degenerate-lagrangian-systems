using Test
using GeometricIntegrators
import GeometricProblems
import SrkMethodsForDegenerateLagrangianSystems as SRK

# All problem modules export `iodeproblem` and `Δt`, so they are addressed by their module.
const problems = (
    GeometricProblems.LotkaVolterra2d,
    GeometricProblems.MasslessChargedParticleSingular,
    GeometricProblems.MasslessChargedParticle,
)

# The Poincaré invariants of `run_poincare`, with a handful of sample points over a handful of time
# steps: what is asserted here is the wiring — that the ensemble is built, advected and evaluated,
# that both figures are written where the woven page expects them, and that a diverging method is
# survived rather than propagated. The physics is asserted upstream, in the GeometricProblems test
# suite, where the invariant error is checked to converge at the order of the method.
#
# `NSURFACE` is 45 = 9·10/2, the next Padua number below the production 231; the Chebyshev plan
# rounds any other count up to one anyway.
const NLOOP_TEST = 16
const NSURFACE_TEST = 45
const NT_TEST = 3

@testset "Poincaré invariants — $(nameof(problem))" for problem in problems
    spec = (
        loop = problem.f_loop,
        surface = problem.f_surface,
        first = problem.poincare_invariant_1st,
        second = problem.poincare_invariant_2nd,
    )

    iode =
        problem.iodeproblem(; timestep = problem.Δt, timespan = (0.0, NT_TEST * problem.Δt))

    mktempdir() do dir
        SRK.run_poincare(
            spec,
            iode,
            :test,
            ((VPRKGauss(2), "gauss2"),),
            dir;
            nloop = NLOOP_TEST,
            nsurface = NSURFACE_TEST,
        )

        @test isfile(joinpath(dir, "gauss2_poincare_1st.png"))
        @test isfile(joinpath(dir, "gauss2_poincare_2nd.png"))
    end

    # `invariant_error` is what carries the partial-result contract: it returns the invariant over
    # as many time steps as every member of the ensemble survived.
    pinv = spec.first(NLOOP_TEST)
    ts, Is, last_good, ntotal = SRK.invariant_error(pinv, iode, VPRKGauss(2), spec.loop)

    @test last_good == ntotal == NT_TEST
    @test length(ts) == length(Is) == NT_TEST + 1
    @test all(isfinite, Is)
    @test !iszero(Is[begin])
end
