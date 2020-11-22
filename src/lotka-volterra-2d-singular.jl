module LotkaVolterra2dSingularSRK

    const Δt = 0.1
    const nt = 100000

    const PLOT_DIR = "figures"
    const SYMP_DIR = "symplecticity"

    using GeometricIntegrators

    using GeometricProblems.LotkaVolterra2dSingular
    using GeometricProblems.LotkaVolterra2dPlots

    set_config(:nls_atol, 1E-14)
    set_config(:nls_rtol, 1E-14)
    set_config(:nls_nmax, 100);

    include("common.jl")
    include("tableau_lists.jl")

end
