
using Weave

Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include("../src/massless-charged-particle-singular.jl")


weave("weave/massless-charged-particle-singular-vprk-gauss.jmd",
         out_path = "build/massless-charged-particle-singular",
         doctype = "github",
         mod = MasslessChargedParticleSingularSRK)

weave("weave/massless-charged-particle-singular-vprk-lobatto-ab.jmd",
         out_path = "build/massless-charged-particle-singular",
         doctype = "github",
         mod = MasslessChargedParticleSingularSRK)

weave("weave/massless-charged-particle-singular-vprk-lobatto-ba.jmd",
         out_path = "build/massless-charged-particle-singular",
         doctype = "github",
         mod = MasslessChargedParticleSingularSRK)

weave("weave/massless-charged-particle-singular-vprk-radau.jmd",
         out_path = "build/massless-charged-particle-singular",
         doctype = "github",
         mod = MasslessChargedParticleSingularSRK)

weave("weave/massless-charged-particle-singular-firk.jmd",
         out_path = "build/massless-charged-particle-singular",
         doctype = "github",
         mod = MasslessChargedParticleSingularSRK)

weave("weave/massless-charged-particle-singular-srk.jmd",
         out_path = "build/massless-charged-particle-singular",
         doctype = "github",
         mod = MasslessChargedParticleSingularSRK)
