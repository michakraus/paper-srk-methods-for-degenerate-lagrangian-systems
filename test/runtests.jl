
using Test
using GeometricIntegrators
import GeometricProblems
using SrkMethodsForDegenerateLagrangianSystems
import SrkMethodsForDegenerateLagrangianSystems as SRK

const tableaus = (
    "Gauss-Legendre VPRK"      => tableaus_vprk_glrk(),
    "Lobatto IIIA-IIIB VPRK"   => tableaus_vprk_lobatto_IIIA_IIIB(),
    "Lobatto IIIB-IIIA VPRK"   => tableaus_vprk_lobatto_IIIB_IIIA(),
    "Radau IIA VPRK"           => tableaus_vprk_radau(),
    "Gauss-Legendre SRK"       => tableaus_srk_glrk(),
    "Gauss-Legendre FIRK"      => tableaus_firk_glrk(),
)

const nt = 1

# All problem modules export `iodeproblem` and `Δt`, so they are addressed by their module.
const problems = (
    GeometricProblems.LotkaVolterra2d,
    GeometricProblems.MasslessChargedParticleSingular,
    GeometricProblems.MasslessChargedParticle,
)

# Integrate a single time step. A `DomainError` is a legitimate outcome for these
# degenerate Lagrangians – a stage value may leave the domain of the logarithm – and is
# tolerated; every other exception propagates and fails the test. The suite runs the
# diverging methods on purpose and only asks whether they raise, so `verbosity = 0` keeps
# the line search from reporting its failures here.
function integrates(iode, method)
    try
        integrate(iode, method; f_abstol = 1E-14, f_reltol = 1E-14, verbosity = 0)
    catch ex
        ex isa DomainError || rethrow()
    end
    return true
end

@testset "$(nameof(problem))" for problem in problems
    iode = problem.iodeproblem(; timestep = problem.Δt, timespan = (0.0, nt * problem.Δt))

    @testset "$(family)" for (family, list) in tableaus
        @testset "$(file)" for (method, file) in list
            @test integrates(iode, method)
        end
    end
end


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
    spec = (loop    = problem.f_loop,
            surface = problem.f_surface,
            first   = problem.poincare_invariant_1st,
            second  = problem.poincare_invariant_2nd)

    iode = problem.iodeproblem(; timestep = problem.Δt,
                                 timespan = (0.0, NT_TEST * problem.Δt))

    mktempdir() do dir
        SRK.run_poincare(spec, iode, :test, ((VPRKGauss(2), "gauss2"),), dir;
                         nloop = NLOOP_TEST, nsurface = NSURFACE_TEST)

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
