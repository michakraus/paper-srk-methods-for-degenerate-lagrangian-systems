
using Test
using GeometricIntegrators
import GeometricProblems
using SrkMethodsForDegenerateLagrangianSystems

const tableaus = (
    tableaus_vprk_glrk(),
    tableaus_vprk_lobatto_IIIA_IIIB(),
    tableaus_vprk_lobatto_IIIB_IIIA(),
    tableaus_vprk_radau(),
    tableaus_srk_glrk(),
    tableaus_firk_glrk(),
)

const nt = 1

# All problem modules export `iodeproblem` and `Δt`, so they are addressed by their module.
const problems = (
    GeometricProblems.LotkaVolterra2d,
    GeometricProblems.MasslessChargedParticleSingular,
    GeometricProblems.MasslessChargedParticle,
)

for problem in problems
    iode = problem.iodeproblem(; timestep = problem.Δt, timespan = (0.0, nt * problem.Δt))

    for list in tableaus
        for run in list
            method, file = run

            @test_nowarn begin
                try
                    integrate(iode, method; f_abstol = 1E-14, f_reltol = 1E-14, max_iterations = 100)
                catch ex
                    if isa(ex, DomainError)
                        @warn("DOMAIN ERROR: Integrator crashed")
                    else
                        throw(ex)
                    end
                end
            end
        end
    end
end
