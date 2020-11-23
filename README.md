# Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://michakraus.github.io/paper-srk-methods-for-degenerate-lagrangian-systems/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://michakraus.github.io/paper-srk-methods-for-degenerate-lagrangian-systems/dev)
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.4285894.svg)](https://doi.org/10.5281/zenodo.4285894)

This packages serves to document the examples from the paper *Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems*.

The integrators are implemented in [GeometricIntegrators.jl](https://github.com/JuliaGNI/GeometricIntegrators.jl) in the module `GeometricIntegrators.Integrators.SPARK` and the example problems in [GeometricProblems.jl](https://github.com/JuliaGNI/GeometricProblems.jl).
The corresponding plots can be found in the [documentation](https://michakraus.github.io/paper-srk-methods-for-degenerate-lagrangian-systems/stable).

## References

* Michael Kraus. Symplectic Runge-Kutta Methods for Degenerate Lagrangian Systems. 2020.

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

## Licenses

This package is licensed under the [MIT "Expat" License](LICENSE.md).
All figures are licensed under the Creative Commons [CC BY-NC-SA 4.0 License](https://creativecommons.org/licenses/by-nc-sa/4.0/).
