module SrkMethodsForDegenerateLagrangianSystems

    include("common.jl")
    include("tableau_lists.jl")

    # Makie themes set in a module body are applied during precompilation only, so the
    # shared plotting style has to be activated when the module is loaded.
    __init__() = set_theme!(PLOT_THEME)

    export tableaus_vprk_glrk,
           tableaus_vprk_lobatto_IIIA_IIIB,
           tableaus_vprk_lobatto_IIIB_IIIA,
           tableaus_vprk_radau,
           tableaus_srk_glrk,
           tableaus_firk_glrk

    # `run_list` and `run_poincare` are deliberately *not* exported: every problem module in
    # `src/<problem>.jl` defines its own wrappers, which bind the problem's plot recipes and its
    # phase space parameterisations, and scripts commonly `using` both this package and a problem
    # module.

end
