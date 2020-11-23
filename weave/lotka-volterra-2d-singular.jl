
using Weave

Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include("../src/lotka-volterra-2d-singular.jl")


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
