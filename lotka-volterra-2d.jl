
using Weave

Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include("src/lotka-volterra-2d-singular.jl")
include("src/lotka-volterra-2d-symmetric.jl")


weave("weave/lotka-volterra-2d-symmetric-vprk-gauss.jmd",
         out_path = "build/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("weave/lotka-volterra-2d-symmetric-vprk-lobatto-ab.jmd",
         out_path = "build/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("weave/lotka-volterra-2d-symmetric-vprk-lobatto-ba.jmd",
         out_path = "build/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("weave/lotka-volterra-2d-symmetric-vprk-radau.jmd",
         out_path = "build/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("weave/lotka-volterra-2d-symmetric-firk.jmd",
         out_path = "build/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("weave/lotka-volterra-2d-symmetric-srk.jmd",
         out_path = "build/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)


weave("weave/lotka-volterra-2d-singular-vprk-gauss.jmd",
         out_path = "build/lotka-volterra-2d-singular",
         doctype = "github",
         mod = LotkaVolterra2dSingularSRK)

weave("weave/lotka-volterra-2d-singular-vprk-lobatto-ab.jmd",
         out_path = "build/lotka-volterra-2d-singular",
         doctype = "github",
         mod = LotkaVolterra2dSingularSRK)

weave("weave/lotka-volterra-2d-singular-vprk-lobatto-ba.jmd",
         out_path = "build/lotka-volterra-2d-singular",
         doctype = "github",
         mod = LotkaVolterra2dSingularSRK)

weave("weave/lotka-volterra-2d-singular-vprk-radau.jmd",
         out_path = "build/lotka-volterra-2d-singular",
         doctype = "github",
         mod = LotkaVolterra2dSingularSRK)

weave("weave/lotka-volterra-2d-singular-firk.jmd",
         out_path = "build/lotka-volterra-2d-singular",
         doctype = "github",
         mod = LotkaVolterra2dSingularSRK)

weave("weave/lotka-volterra-2d-singular-srk.jmd",
         out_path = "build/lotka-volterra-2d-singular",
         doctype = "github",
         mod = LotkaVolterra2dSingularSRK)
