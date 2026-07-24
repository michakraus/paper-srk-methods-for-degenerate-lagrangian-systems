
all: lvsingular lvsymmetric mcpsingular mcpstandard

lvsingular:
	julia --color=yes --project weave/lotka-volterra-2d-singular.jl

lvsymmetric:
	julia --color=yes --project weave/lotka-volterra-2d-symmetric.jl

mcpsingular:
	julia --color=yes --project weave/massless-charged-particle-singular.jl

mcpstandard:
	julia --color=yes --project weave/massless-charged-particle-standard.jl

clean:
	rm -Rf build
