
PROBLEMS = lotka-volterra-2d-singular \
           lotka-volterra-2d-symmetric \
           massless-charged-particle-singular \
           massless-charged-particle-standard

PAGES = srk \
        firk \
        vprk-gauss \
        vprk-lobatto-ab \
        vprk-lobatto-ba \
        vprk-radau

# One target per woven page, mirroring the matrix of .github/workflows/Documentation.yaml:
# `make -j8 weave` reproduces its fan-out and `make -k` its `fail-fast: false`, so that a
# crashing integrator does not cost us the remaining pages.
PAGE_TARGETS = $(foreach problem,$(PROBLEMS),$(addprefix page/$(problem)/,$(PAGES)))

.PHONY: all documenter weave clean $(PAGE_TARGETS) $(PROBLEMS)

all: weave documenter

documenter: weave
	julia --color=yes --project=.. make.jl

weave: $(PAGE_TARGETS)

$(PAGE_TARGETS):
	julia --color=yes --project=.. weave.jl $(word 2,$(subst /, ,$@)) $(word 3,$(subst /, ,$@))

# `make -j6 lotka-volterra-2d-singular` weaves all pages of one problem.
define problem_target
$(1): $(addprefix page/$(1)/,$(PAGES))
endef
$(foreach problem,$(PROBLEMS),$(eval $(call problem_target,$(problem))))

clean:
	rm -Rf build
	rm -Rf src/*.html
	$(foreach problem,$(PROBLEMS),rm -Rf src/$(problem);)
