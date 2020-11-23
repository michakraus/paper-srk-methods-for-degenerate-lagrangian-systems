
all: lvsingular lvsymmetric

lvsingular:
	julia --color=yes --project weave/lotka-volterra-2d-singular.jl

lvsymmetric:
	julia --color=yes --project weave/lotka-volterra-2d-symmetric.jl

clean:
	rm -Rf build
