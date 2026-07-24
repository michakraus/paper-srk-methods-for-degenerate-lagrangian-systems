
using Test
using GeometricIntegrators
using GeometricProblems.LotkaVolterra2d
using GeometricProblems.LotkaVolterra2d: Δt
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
const iode = iodeproblem(; timestep = Δt, timespan = (0.0, nt * Δt))

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
