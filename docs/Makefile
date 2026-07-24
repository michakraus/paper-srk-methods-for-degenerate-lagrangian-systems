
PROBLEMS = lotka-volterra-2d-singular \
           lotka-volterra-2d-symmetric \
           massless-charged-particle-singular \
           massless-charged-particle-standard

.PHONY: documenter weave $(PROBLEMS) clean

all: weave documenter

documenter: weave
	julia --color=yes --project=.. make.jl

# The CI workflow instead builds the individual pages of each problem in parallel;
# see .github/workflows/Documentation.yaml and the usage comment in weave.jl.
weave: $(PROBLEMS)

$(PROBLEMS):
	julia --color=yes --project=.. weave.jl $@

clean:
	rm -Rf build
	rm -Rf src/*.html
	$(foreach problem,$(PROBLEMS),rm -Rf src/$(problem);)
