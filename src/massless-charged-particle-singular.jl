module MasslessChargedParticleSingularSRK

    const Δt = 0.1
    const nt = 100000

    using GeometricIntegrators

    # "Singular" (one-component) vector potential: the form expected by the SRK/DVRK
    # integrators. The plot recipes are provided by the problem module itself.
    using GeometricProblems.MasslessChargedParticleSingular

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
