module LotkaVolterra2dSymmetricSRK

    const Δt = 0.1
    const nt = 100000

    using GeometricIntegrators

    using GeometricProblems.LotkaVolterra2dSymmetric
    # Both Lotka-Volterra gauges share the plot recipes of the standard problem.
    using GeometricProblems.LotkaVolterra2d: plot_solution, plot_phase_portrait, plot_traces

    import SrkMethodsForDegenerateLagrangianSystems as SRK
    using SrkMethodsForDegenerateLagrangianSystems: tableaus_vprk_glrk,
        tableaus_vprk_lobatto_IIIA_IIIB, tableaus_vprk_lobatto_IIIB_IIIA,
        tableaus_vprk_radau, tableaus_srk_glrk, tableaus_firk_glrk

    const PLOT_RECIPES = (solution       = plot_solution,
                          phase_portrait = plot_phase_portrait,
                          traces         = plot_traces)

    run_list(args...; kwargs...) = SRK.run_list(PLOT_RECIPES, args...; kwargs...)

    export run_list

end
