
.PHONY: documenter weave

all: weave documenter

documenter: weave
	julia --color=yes --project=.. make.jl

weave:
	julia --color=yes --project=.. weave-lotka-volterra-2d-singular.jl
	julia --color=yes --project=.. weave-lotka-volterra-2d-symmetric.jl

clean:
	rm -Rf build
	rm -Rf src/*.html
	rm -Rf src/lotka-volterra-2d-singular
	rm -Rf src/lotka-volterra-2d-symmetric
