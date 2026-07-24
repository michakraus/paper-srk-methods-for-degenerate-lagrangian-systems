
using Weave

Weave.set_chunk_defaults!(:echo => false, :results => "raw")

include("../src/massless-charged-particle-standard.jl")


weave("weave/massless-charged-particle-standard-vprk-gauss.jmd",
         out_path = "build/massless-charged-particle-standard",
         doctype = "github",
         mod = MasslessChargedParticleStandardSRK)

weave("weave/massless-charged-particle-standard-vprk-lobatto-ab.jmd",
         out_path = "build/massless-charged-particle-standard",
         doctype = "github",
         mod = MasslessChargedParticleStandardSRK)

weave("weave/massless-charged-particle-standard-vprk-lobatto-ba.jmd",
         out_path = "build/massless-charged-particle-standard",
         doctype = "github",
         mod = MasslessChargedParticleStandardSRK)

weave("weave/massless-charged-particle-standard-vprk-radau.jmd",
         out_path = "build/massless-charged-particle-standard",
         doctype = "github",
         mod = MasslessChargedParticleStandardSRK)

weave("weave/massless-charged-particle-standard-firk.jmd",
         out_path = "build/massless-charged-particle-standard",
         doctype = "github",
         mod = MasslessChargedParticleStandardSRK)

weave("weave/massless-charged-particle-standard-srk.jmd",
         out_path = "build/massless-charged-particle-standard",
         doctype = "github",
         mod = MasslessChargedParticleStandardSRK)
