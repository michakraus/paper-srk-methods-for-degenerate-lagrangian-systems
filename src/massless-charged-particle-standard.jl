module MasslessChargedParticleStandardSRK

    const Δt = 0.1
    const nt = 100000

    # The Poincaré invariants advect a few hundred trajectories per method instead of one, so they
    # run over a correspondingly shorter time interval — at the same time step.
    const nt_poincare = 1000

    using GeometricIntegrators

    # Standard (two-component) vector potential: gauge-equivalent to the singular one, but
    # not of the form expected by the SRK/DVRK integrators. The plot recipes are provided
    # by the problem module itself.
    using GeometricProblems.MasslessChargedParticle

    import SrkMethodsForDegenerateLagrangianSystems as SRK
    using SrkMethodsForDegenerateLagrangianSystems: tableaus_vprk_glrk,
        tableaus_vprk_lobatto_IIIA_IIIB, tableaus_vprk_lobatto_IIIB_IIIA,
        tableaus_vprk_radau, tableaus_srk_glrk, tableaus_firk_glrk

    const PLOT_RECIPES = (solution       = plot_solution,
                          phase_portrait = plot_phase_portrait,
                          traces         = plot_traces)

    # Phase space parameterisations and invariant constructors, all supplied by GeometricProblems:
    # `f_loop`/`f_surface` are the curve and the surface the invariants are taken over,
    # `poincare_invariant_1st`/`_2nd` build them over this gauge's own one- and two-form.
    const PI_SPEC = (loop    = MasslessChargedParticle.f_loop,
                     surface = MasslessChargedParticle.f_surface,
                     first   = MasslessChargedParticle.poincare_invariant_1st,
                     second  = MasslessChargedParticle.poincare_invariant_2nd)

    run_list(args...; kwargs...) = SRK.run_list(PLOT_RECIPES, args...; kwargs...)
    run_poincare(args...; kwargs...) = SRK.run_poincare(PI_SPEC, args...; kwargs...)

    export run_list, run_poincare

end
