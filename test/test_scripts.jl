
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

# The `run_poincare` wrappers, with the sample counts turned right down: the default 200 loop and
# 231 surface points are a few hundred trajectories per method, which is a weave build, not a
# script run.
LotkaVolterra2dSingularSRK.run_poincare(
    GeometricProblems.LotkaVolterra2dSingular.iodeproblem(),
    :TableauVPRK, tableaus_vprk_glrk(); nloop = 16, nsurface = 45)

MasslessChargedParticleSingularSRK.run_poincare(
    GeometricProblems.MasslessChargedParticleSingular.iodeproblem(),
    :TableauVPRK, tableaus_vprk_glrk(); nloop = 16, nsurface = 45)
