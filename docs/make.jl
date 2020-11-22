using Documenter
using GeometricIntegrators

makedocs(;
    authors="Michael Kraus",
    sitename="Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://michakraus.github.io/papers-srk-methods-for-degenerate-lagrangian-systems",
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
    ],
)

deploydocs(;
    repo="github.com/michakraus/papers-srk-methods-for-degenerate-lagrangian-systems.jl",
    devbranch="main"
)
