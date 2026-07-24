using Documenter
using GeometricIntegrators

makedocs(;
    authors="Michael Kraus",
    sitename="Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems",
    # Some integrators crash on the degenerate Lagrangian and therefore produce no
    # figures; their pages reference those (missing) images unconditionally. Downgrade
    # the resulting broken-link errors to warnings (Documenter ≥ 1 errors by default).
    warnonly=[:cross_references],
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://michakraus.github.io/paper-srk-methods-for-degenerate-lagrangian-systems",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",

        "Lotka-Volterra 2d (singular Lagrangian)" => [
            "Symplectic Gauss-Legendre Runge-Kutta Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-srk.md",
            "Gauss-Legendre Runge-Kutta Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-firk.md",
            "Gauss-Legendre VPRK Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-gauss.md",
            "Lobatto IIIA-IIIB VPRK Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto-ab.md",
            "Lobatto IIIB-IIIA VPRK Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto-ba.md",
            "Radau VPRK Methods" => "lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-radau.md",
        ],

        "Lotka-Volterra 2d (symmetric Lagrangian)" => [
            "Symplectic Gauss-Legendre Runge-Kutta Methods" => "lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-srk.md",
            "Gauss-Legendre VPRK Methods" => "lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-gauss.md",
            "Gauss-Legendre Runge-Kutta Methods" => "lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-firk.md",
            "Lobatto IIIA-IIIB VPRK Methods" => "lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-lobatto-ab.md",
            "Lobatto IIIB-IIIA VPRK Methods" => "lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-lobatto-ba.md",
            "Radau VPRK Methods" => "lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-radau.md",
        ],

        "Massless Charged Particle (singular vector potential)" => [
            "Symplectic Gauss-Legendre Runge-Kutta Methods" => "massless-charged-particle-singular/massless-charged-particle-singular-srk.md",
            "Gauss-Legendre Runge-Kutta Methods" => "massless-charged-particle-singular/massless-charged-particle-singular-firk.md",
            "Gauss-Legendre VPRK Methods" => "massless-charged-particle-singular/massless-charged-particle-singular-vprk-gauss.md",
            "Lobatto IIIA-IIIB VPRK Methods" => "massless-charged-particle-singular/massless-charged-particle-singular-vprk-lobatto-ab.md",
            "Lobatto IIIB-IIIA VPRK Methods" => "massless-charged-particle-singular/massless-charged-particle-singular-vprk-lobatto-ba.md",
            "Radau VPRK Methods" => "massless-charged-particle-singular/massless-charged-particle-singular-vprk-radau.md",
        ],

        "Massless Charged Particle (standard vector potential)" => [
            "Symplectic Gauss-Legendre Runge-Kutta Methods" => "massless-charged-particle-standard/massless-charged-particle-standard-srk.md",
            "Gauss-Legendre Runge-Kutta Methods" => "massless-charged-particle-standard/massless-charged-particle-standard-firk.md",
            "Gauss-Legendre VPRK Methods" => "massless-charged-particle-standard/massless-charged-particle-standard-vprk-gauss.md",
            "Lobatto IIIA-IIIB VPRK Methods" => "massless-charged-particle-standard/massless-charged-particle-standard-vprk-lobatto-ab.md",
            "Lobatto IIIB-IIIA VPRK Methods" => "massless-charged-particle-standard/massless-charged-particle-standard-vprk-lobatto-ba.md",
            "Radau VPRK Methods" => "massless-charged-particle-standard/massless-charged-particle-standard-vprk-radau.md",
        ],
    ],
)

deploydocs(;
    repo="github.com/michakraus/paper-srk-methods-for-degenerate-lagrangian-systems",
    devbranch="main"
)
