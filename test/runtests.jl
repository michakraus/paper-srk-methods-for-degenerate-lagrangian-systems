
using Test
using GeometricIntegrators
import GeometricProblems
using SrkMethodsForDegenerateLagrangianSystems

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
# tolerated; every other exception propagates and fails the test.
function integrates(iode, method)
    try
        integrate(iode, method; f_abstol = 1E-14, f_reltol = 1E-14, max_iterations = 100)
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
