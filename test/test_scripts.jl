
include("../src/lotka-volterra-2d-singular.jl")
include("../src/massless-charged-particle-singular.jl")

import GeometricProblems
using SrkMethodsForDegenerateLagrangianSystems

# The problem modules both export `run_list`, so they are addressed by their module.
LotkaVolterra2dSingularSRK.run_list(
    GeometricProblems.LotkaVolterra2dSingular.iodeproblem(),
    :TableauVPRK, tableaus_vprk_glrk())

MasslessChargedParticleSingularSRK.run_list(
    GeometricProblems.MasslessChargedParticleSingular.iodeproblem(),
    :TableauVPRK, tableaus_vprk_glrk())
