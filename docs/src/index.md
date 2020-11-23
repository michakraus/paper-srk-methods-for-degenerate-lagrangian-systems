# Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems

This packages serves to document the examples from the paper *Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems*. The integrators are implemented in [GeometricIntegrators.jl](https://github.com/JuliaGNI/GeometricIntegrators.jl) in the modules `GeometricIntegrators.Integrators` and `GeometricIntegrators.Integrators.VPRK`, and the example problems in [GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl).

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

If you use the integrators described in the article above, please cite GeometricIntegrators.jl as

```
@misc{Kraus:2020:GeometricIntegrators,
  title={GeometricIntegrators.jl: A Julia library of geometric integrators for ordinary differential equations and differential algebraic equations},
  author={Kraus, Michael},
  year={2020},
  howpublished={\url{https://github.com/JuliaGNI/GeometricIntegrators.jl}},
  doi={10.5281/zenodo.3648325}
}
```

If you use the figures or implementations provided here, please cite this repository as

```
@misc{Kraus:2020:SRKMethodsRepo,
  title={Companion Repository to ``Symplectic {R}unge--{K}utta Methods for Degenerate {L}agrangian Systems''},
  author={Kraus, Michael},
  year={2020},
  month={11},
  howpublished={\url{https://github.com/michakraus/paper-srk-methods-for-degenerate-lagrangian-systems}},
  doi={10.5281/zenodo.4285894}
}
```

All figures are licensed under the Creative Commons [CC BY-NC-SA 4.0 License](https://creativecommons.org/licenses/by-nc-sa/4.0/).
