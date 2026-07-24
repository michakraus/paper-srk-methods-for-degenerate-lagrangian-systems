module LotkaVolterra2dSingularSRK

    const Δt = 0.1
    const nt = 100000

    const PLOT_DIR = "figures"
    const SYMP_DIR = "symplecticity"

    using GeometricIntegrators

    using GeometricProblems.LotkaVolterra2dSingular

    include("common.jl")
    include("tableau_lists.jl")

    export run_list

end
