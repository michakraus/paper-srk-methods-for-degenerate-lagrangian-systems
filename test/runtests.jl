
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

const iode = lotka_volterra_2d_iode()
const nt = 10

for list in tableaus
    for run in list
        tab, file = run

        if length(run) ≥ 3
            integrator = run[3]
        else
            integrator = Integrator
        end

        @test_nowarn begin
            sol = Solution(iode, Δt, nt)
            int = integrator(iode, tab, Δt)
            integrate!(int, sol)
        end
    end
end
