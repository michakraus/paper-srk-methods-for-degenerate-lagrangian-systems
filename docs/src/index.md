# Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems

This packages serves to document the examples from the paper *Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems*.

The integrators are implemented in [GeometricIntegrators.jl](https://github.com/JuliaGNI/GeometricIntegrators.jl) in the module `GeometricIntegrators.Integrators.SPARK` and the example problems in [GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl).
The corresponding plots can be found in the [documentation](https://michakraus.github.io/srk-methods-for-degenerate-lagrangian-systems.jl/stable).

## Numerical Examples

### Lotka-Volterra 2d (singular Lagrangian)

* [Symplectic Gauss-Legendre Runge-Kutta Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-srk.md)
* [Gauss-Legendre Runge-Kutta Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-firk.md)
* [Gauss-Legendre VPRK Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-gauss.md)
* [Lobatto IIIA-IIIB VPRK Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto-ab.md)
* [Lobatto IIIB-IIIA VPRK Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-lobatto-ba.md)
* [Radau IIA VPRK Methods](lotka-volterra-2d-singular/lotka-volterra-2d-singular-vprk-radau.md)

### Lotka-Volterra 2d (symmetric Lagrangian)

* [Symplectic Gauss-Legendre Runge-Kutta Methods](lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-srk.md)
* [Gauss-Legendre Runge-Kutta Methods](lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-firk.md)
* [Gauss-Legendre VPRK Methods](lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-gauss.md)
* [Lobatto IIIA-IIIB VPRK Methods](lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-lobatto-ab.md)
* [Lobatto IIIB-IIIA VPRK Methods](lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-lobatto-ba.md)
* [Radau IIA VPRK Methods](lotka-volterra-2d-symmetric/lotka-volterra-2d-symmetric-vprk-radau.md)

## References

* Michael Kraus. Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems.
