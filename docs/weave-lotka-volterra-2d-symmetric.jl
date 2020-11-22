using GeometricIntegrators
using Weave

GeometricIntegrators.set_config(:verbosity, 0)

Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include("../src/lotka-volterra-2d-symmetric.jl")

weave("../weave/lotka-volterra-2d-symmetric-vprk-gauss.jmd",
         out_path = "src/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("../weave/lotka-volterra-2d-symmetric-vprk-lobatto-ab.jmd",
         out_path = "src/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("../weave/lotka-volterra-2d-symmetric-vprk-lobatto-ba.jmd",
         out_path = "src/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("../weave/lotka-volterra-2d-symmetric-vprk-radau.jmd",
         out_path = "src/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("../weave/lotka-volterra-2d-symmetric-firk.jmd",
         out_path = "src/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)

weave("../weave/lotka-volterra-2d-symmetric-srk.jmd",
         out_path = "src/lotka-volterra-2d-symmetric",
         doctype = "github",
         mod = LotkaVolterra2dSymmetricSRK)
