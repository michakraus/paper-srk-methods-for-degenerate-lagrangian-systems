
using Logging
using Markdown
using Markdown: MD, Paragraph, LineBreak

using CairoMakie

using GeometricIntegrators
import GeometricIntegratorsBase
const GIB = GeometricIntegratorsBase
using SimpleSolvers: NonlinearSolverException

using GeometricProblems.Diagnostics: plot_energy_error, plot_energy_drift, plot_constraint_error

using PoincareInvariants


# Output directories for the figures (and, for symmetry with the SPARK companion package,
# the symplecticity conditions, which are not computed here).
const PLOT_DIR = "figures"
const SYMP_DIR = "symplecticity"


# Number of points at which the loop and the surface of the Poincaré invariants are sampled.
# `FirstFourierPlan` takes any number of loop points; the surface's `SecondChebyshevPlan` samples at
# Padua points and rounds the count up to the next Padua number, of which 231 = 21·22/2 is one.
const NLOOP = 200
const NSURFACE = 231

# The second invariant is evaluated over a shorter time interval than the first.
#
# Its Chebyshev quadrature interpolates the *advected* surface, which the flow shears, and the
# polynomial degree needed to resolve that grows with the time span. Past the point where the degree
# no longer suffices, the figure reports the quadrature failing rather than the method — and it does
# so identically for every method in a family, which is how one tells the two apart.
#
# Where that point lies has to be measured against a *refined reference*, not against a fixed
# tolerance: these methods conserve the invariant to some 5e-13, so quadrature noise becomes visible
# long before it reaches any absolute threshold one might pick, and picking one overestimates the
# usable span by half again. Measured on Lotka-Volterra 2d with `DVRK(Gauss(6))`, comparing 231
# points against a converged 1891: the coarse curve tracks the truth to within 10% up to t ≈ 15 and
# overshoots it 4.8× by t = 20. At 528 points the limit moves out to t ≈ 30. The interval below
# therefore carries the trend faithfully but shows some scatter over its last few units.
#
# The first invariant has no such limit: a Fourier plan on a closed loop holds ~1e-13 over the full
# t = 100. Refining the surface rather than shortening its interval does not pay — the points needed
# grow faster than the horizon and cost as their product, so covering t = 100 would take some 2350
# points and roughly ten times the runtime of the whole diagnostic.
const T_POINCARE_2ND = 20.0


# Shared Makie plotting style (kept identical to the DVI and SPARK companion packages).
# Larger fonts and thicker lines than the Makie defaults, tuned for the fixed figure sizes
# of the GeometricProblems plot recipes. Unicode axis labels are selected via `latex=false`
# on every plot call below. Activated by the module's `__init__`.
const PLOT_THEME = Theme(
    fontsize = 18,
    Lines    = (linewidth = 2,),
    Scatter  = (markersize = 10,),
    Axis     = (
        xlabelsize     = 22,
        ylabelsize     = 22,
        xticklabelsize = 16,
        yticklabelsize = 16,
        titlesize      = 20,
    ),
)


_linebreak(io) = show(io, "text/markdown", MD(Paragraph([LineBreak()])))


# The degenerate Lagrangians make some of the methods diverge, and the Newton solver then
# fails its line search in every iteration of every time step. Those warnings are turned off
# at the source through `SOLVER_VERBOSITY`, which `SimpleSolvers` shares with its line
# search. The plotting stack offers no such switch: `PlotUtils` emits one unthrottled
# `No strict ticks found` per degenerate axis, so its warnings are dropped on the logging
# side instead and only their count is reported, by `run_list`.
const QUIET_LOG_MODULES = (:PlotUtils, :Makie)
const QUIET_LOG_COUNT = Ref(0)

# Solver verbosity used by `integrate_partial`; `quiet_solver_warnings!` drops it to 0 for
# the weave builds. Interactive sessions keep the default, where the warnings are worth
# having: `SimpleSolvers` rate-limits them to a handful per session.
const SOLVER_VERBOSITY = Ref(1)

struct QuietLogger{L<:AbstractLogger} <: AbstractLogger
    parent::L
end

function Logging.shouldlog(logger::QuietLogger, level, _module, group, id)
    if level < Logging.Error && nameof(_module) ∈ QUIET_LOG_MODULES
        QUIET_LOG_COUNT[] += 1
        return false
    end
    Logging.shouldlog(logger.parent, level, _module, group, id)
end

Logging.min_enabled_level(logger::QuietLogger) = Logging.min_enabled_level(logger.parent)
Logging.catch_exceptions(logger::QuietLogger) = Logging.catch_exceptions(logger.parent)
Logging.handle_message(logger::QuietLogger, args...; kwargs...) =
    Logging.handle_message(logger.parent, args...; kwargs...)

# Turn off the solver warnings and install the filter for the plotting ones. Called by the
# weave driver, not on load, so that interactive sessions keep the warnings unless they ask
# for quiet.
function quiet_solver_warnings!()
    SOLVER_VERBOSITY[] = 0
    global_logger(QuietLogger(global_logger()))
end


# Integrate an IODE step-by-step so that a crash (solver failure, singular matrix,
# NaNs, …) does not discard the whole run: we keep the solution up to the last
# successful time step. Returns `(sol, last_good, err)` where `last_good` is the index
# of the last completed step and `err` is `nothing` (success), `:nan` (NaNs in the
# state), or the caught exception. The steps after `last_good` are padded with the last
# good state so downstream invariant computations never see uninitialized data.
#
# No iteration cap is imposed on the solver: a non-convergent solve is bounded by the
# stagnation detector of `SimpleSolvers`, which gives up after two consecutive steps that
# leave the iterate unmoved while the residual is still large. `warn_iterations = 0` drops
# the bare iteration-count warning, the one solver message that `verbosity` does not gate.
function integrate_partial(iode, method)
    int     = GIB.GeometricIntegrator(iode, method; f_abstol=1E-14, f_reltol=1E-14,
                                      verbosity=SOLVER_VERBOSITY[], warn_iterations=0)
    sol     = GIB.Solution(iode)
    solstep = GIB.solutionstep(int, sol[0])
    state   = GIB.current(solstep)
    nt      = GIB.ntime(sol)

    last_good = 0
    err = nothing

    try
        for n in 1:nt
            GIB.reset!(solstep, GIB.timesteps(sol)[n])
            GIB.integrate!(solstep, int)
            if isnan(state)
                err = :nan
                break
            end
            copy!(sol, state, n)
            last_good = n
        end
    catch ex
        err = ex
    end

    for n in (last_good+1):nt
        sol.q[n] = copy(sol.q[last_good])
        sol.p[n] = copy(sol.p[last_good])
    end

    (sol, last_good, err)
end


# DVRK wraps an inner tableau (e.g. DVRK(Gauss(1))); show it explicitly. All other methods are
# shown as `Name(s)` (e.g. VPRKGauss(2), Gauss(2)).
function _headline(method)
    method isa DVRK && return "DVRK($(tableau(method).name)($(tableau(method).s)))"
    return "$(nameof(typeof(method)))($(tableau(method).s))"
end


# Short, human-readable one-line description of a crash (no stack trace).
function _failure_message(err)
    err === :nan                      && return "NaNs detected in the solution"
    err isa NonlinearSolverException  && return "solver error – " * err.msg
    err isa DomainError               && return "domain error"
    return string(nameof(typeof(err)))
end


# Reference a figure, but only if it was actually produced: a run that crashed early has no
# energy drift data, and one that crashed on the very first step has no figures at all.
# Referencing them regardless leaves broken images on the page and one `invalid local
# link/image` warning per figure in the Documenter build. Returns whether it wrote one.
function _plot_figure_md(file, name, filename)
    isfile(filename) || return false

    show(file, "text/markdown", Markdown.parse("![$name]($filename)"))
    _linebreak(file)

    true
end


# Write the page collecting all figures of one run. Must be called *after* `run_integrator`,
# so that the figures it references already exist on disk.
function write_plots(dir, file, name, fig_suff)

    plot_file = file * ".md"
    omitted = 0

    open(plot_file, "w") do f
        figure(suffix) = _plot_figure_md(f, name, "$(dir)/$(file)$(suffix)$(fig_suff)") || (omitted += 1)

        show(f, "text/markdown", Markdown.parse("# $name"))
        _linebreak(f)

        figure("_solution")
        figure("_traces")

        show(f, "text/markdown", Markdown.parse("## Energy Error"))
        _linebreak(f)

        figure("_energy_error")
        figure("_energy_drift")

        show(f, "text/markdown", Markdown.parse("## Constraint"))
        _linebreak(f)

        figure("_constraint_error")
    end

    omitted > 0 && @warn("Omitted $(omitted) figures from $(plot_file) that were not produced")

    nothing
end


# Save the figure produced by `plot` as `<dir>/<file><suffix><fig_suff>`. A failure is
# reported but not propagated: one diagnostic that cannot be plotted (which happens for
# runs that crash after very few time steps) must not cost us the remaining figures.
function _save_plot(plot, dir, file, suffix, fig_suff)
    try
        save(dir * "/" * file * suffix * fig_suff, plot())
    catch ex
        show(stdout, "text/markdown",
             Markdown.parse("**Plotting $(file)$(suffix) failed: $(_failure_message(ex)).**"))
        _linebreak(stdout)
        @warn("Plotting $(file)$(suffix) failed: $(_failure_message(ex))")
    end
end


# Plot the solution up to time step `last_good` (`:auto` plots the whole solution). All
# time-trace panels are limited to `last_good` and share the full-tspan x-axis, so a
# partial run shows its trajectory up to the crash within the complete time interval.
# `recipes` is a named tuple `(solution, phase_portrait, traces)` of the problem-specific
# GeometricProblems plot recipes; the remaining diagnostics are problem-agnostic.
function make_plots(sol, equ, recipes, dir, file, fig_suff, last_good)
    if !isdir(dir)
        mkdir(dir)
    end

    nt      = ntime(sol)
    ntplot  = last_good ≥ nt ? (:auto) : last_good

    # All GeometricProblems recipes set their own x-limits to the plotted time range, so no
    # post-processing is needed here.
    _save_plot(() -> recipes.solution(sol, equ; latex=false, nt=ntplot), dir, file, "", fig_suff)
    _save_plot(() -> recipes.phase_portrait(sol; latex=false, nt=ntplot), dir, file, "_solution", fig_suff)
    _save_plot(() -> recipes.traces(sol, equ; latex=false, nt=ntplot), dir, file, "_traces", fig_suff)
    _save_plot(() -> plot_energy_error(sol; latex=false, nt=ntplot), dir, file, "_energy_error", fig_suff)

    # Drift is an interval-based diagnostic: `plot_energy_drift` splits the solution into ten
    # intervals and its `nt` counts those, not time steps. Show only the intervals completed
    # before a crash, and skip the plot below two of them: a single point has no drift to
    # show and its degenerate x-range throws. Solutions shorter than ten steps have no
    # intervals at all and make the recipe divide by zero (which happens in local tests only).
    interval = max(div(nt, 10), 1)
    ntdrift  = last_good ≥ nt ? (:auto) : div(last_good, interval)

    if nt ≥ 10 && (ntdrift === :auto || ntdrift ≥ 2)
        _save_plot(() -> plot_energy_drift(sol; latex=false, nt=ntdrift), dir, file, "_energy_drift", fig_suff)
    end

    _save_plot(() -> plot_constraint_error(sol; latex=false, nt=ntplot), dir, file, "_constraint_error", fig_suff)
end


function run_integrator(iode, method, recipes, dir, file, fig_suff)
    sol, last_good, err = integrate_partial(iode, method)

    if err !== nothing
        show(stdout, "text/markdown",
             Markdown.parse("**Simulation crashed after $(last_good) of $(ntime(sol)) time steps: $(_failure_message(err)).**"))
        _linebreak(stdout)
        @warn("Simulation crashed after $(last_good) of $(ntime(sol)) time steps: $(_failure_message(err))")
    end

    # Plot whatever was computed (the trajectory up to the last successful step).
    if last_good ≥ 1
        make_plots(sol, iode, recipes, dir, file, fig_suff, last_good)
    end
end


# `recipes` comes first so that the problem modules in `src/<problem>.jl` can bind it with
# a one-line wrapper `run_list(args...; kwargs...) = SRK.run_list(PLOT_RECIPES, args...; kwargs...)`.
function run_list(recipes, iode, name, list, plot_dir = PLOT_DIR, symp_dir = SYMP_DIR;
                    fig_suff = ".png")

    for run in list
        method, file = run

        headline = _headline(method)

        show(stdout, "text/markdown", Markdown.parse("## $(headline)"))
        _linebreak(stdout)

        show(stdout, "text/markdown", Markdown.parse("[Plots]($file.md)"))
        _linebreak(stdout)

        run_integrator(iode, method, recipes, plot_dir, file, fig_suff)

        # The page of figures is written only now, so that it can leave out the ones this
        # run did not produce; same for the overview figure embedded here.
        write_plots(plot_dir, file, name, fig_suff)

        overview = "$plot_dir/$file$fig_suff"
        isfile(overview) && show(stdout, "text/markdown", Markdown.parse("![$name]($overview)"))

        # Each run leaves a set of Makie figures behind; collecting them here keeps the peak
        # footprint of a whole method family within what a CI runner can hold.
        GC.gc()
    end

    if QUIET_LOG_COUNT[] > 0
        @info("Suppressed $(QUIET_LOG_COUNT[]) plotting warnings so far (see QUIET_LOG_MODULES)")
    end

    nothing
end


# Advect the sampled loop or surface and evaluate the Poincaré invariant along the way.
#
# The ensemble is integrated one member at a time through `integrate_partial` rather than with
# `integrate(::EnsembleProblem, …)`: the methods studied here diverge on purpose, and a single
# diverging member must cost only its own trajectory, not the whole figure. The result is
# truncated to the first member that failed, so that no padded state enters the invariant.
#
# Returns `(ts, Is, last_good, nt)`, or `nothing` if not one member survived its first step.
function invariant_error(pinv, iode, method, init)
    # `PIEnsembleProblem` samples the parameterisation at the points the invariant's plan
    # prescribes and seeds each member's momentum from the equation's own one-form, which is what
    # a degenerate Lagrangian needs: the momentum is not free, it is ϑ(q).
    ensemble = PIEnsembleProblem(iode, pinv, init)

    sols = Vector{Any}(undef, nsamples(ensemble))
    last_good = typemax(Int)

    for (i, prob) in enumerate(ensemble)
        sols[i], lg, _ = integrate_partial(prob, method)
        last_good = min(last_good, lg)
    end

    last_good ≥ 1 || return nothing

    # `compute!` takes one trajectory per sample point, each a vector of phase space points. These
    # Lagrangians are degenerate, so the loop and the surface live in the two-dimensional
    # configuration space alone and only `q` enters; the momentum never does.
    ts = [sols[begin].t[n] for n in 0:last_good]
    trajectories = [[sol.q[n] for n in 0:last_good] for sol in sols]

    (ts, compute!(pinv, trajectories, ts, parameters(iode)), last_good, ntime(sols[begin]))
end


# Restrict a problem to the first `T` units of its time interval, keeping its time step, so that
# the two invariants of a run can be evaluated over different spans. `nothing` leaves the problem
# alone, and so does a `T` the problem does not reach — which is what keeps the short runs of the
# test suite intact.
_horizon(prob, ::Nothing) = prob

function _horizon(prob, T)
    t₀, t₁ = timespan(prob)
    T ≥ t₁ - t₀ ? prob : similar(prob; timespan = (t₀, t₀ + T))
end


# Relative error of a Poincaré invariant over time, in the style of
# `PoincareInvariants.plot_invariant`: linear axes, scatter, dashed zero line. That function
# cannot be used directly, as it takes an `EnsembleSolution`, which the per-member integration
# above deliberately does not build.
function plot_invariant_error(ts, Is, symbol, title)
    fig = Figure()
    ax  = Axis(fig[1, 1]; xlabel = "t", title = title,
               ylabel = "Relative Error ($(symbol)(t)-$(symbol)(0))/$(symbol)(0)")

    hlines!(ax, [0.0]; color = :gray, linestyle = :dash)
    scatter!(ax, ts, (Is .- Is[begin]) ./ Is[begin])
    xlims!(ax, first(ts), last(ts))

    fig
end


# The first and second Poincaré invariant of every method in `list`, over the same time step as
# the trajectory diagnostics of `run_list` but a much shorter time interval: one run advects a
# few hundred trajectories instead of one, so the time span is set by the problem module's
# `nt_poincare` rather than its `nt`.
#
# `spec` comes first for the same reason `recipes` does in `run_list`: the problem modules bind it
# with a one-line wrapper. It is a named tuple `(loop, surface, first, second)` of the problem's
# phase space parameterisations and invariant constructors, all four supplied by GeometricProblems.
function run_poincare(spec, iode, name, list, plot_dir = PLOT_DIR;
                        fig_suff = ".png", nloop = NLOOP, nsurface = NSURFACE,
                        t_2nd = T_POINCARE_2ND)

    isdir(plot_dir) || mkpath(plot_dir)

    # One invariant object for the whole list: it depends on the problem's one- or two-form and on
    # the number of sample points only, not on the method that advects those points. The last
    # element is the time interval to evaluate it over, `nothing` meaning the problem's own; see
    # `T_POINCARE_2ND` for why the second invariant gets a shorter one.
    invariants = (("_poincare_1st", "I₁", spec.first(nloop),     spec.loop,    nothing),
                  ("_poincare_2nd", "I₂", spec.second(nsurface), spec.surface, t_2nd))

    for run in list
        method, file = run

        headline = _headline(method)

        show(stdout, "text/markdown", Markdown.parse("### $(headline)"))
        _linebreak(stdout)

        for (suffix, symbol, pinv, init, horizon) in invariants
            result = invariant_error(pinv, _horizon(iode, horizon), method, init)

            if result === nothing
                show(stdout, "text/markdown",
                     Markdown.parse("**No $(symbol): the ensemble crashed on its first time step.**"))
                _linebreak(stdout)
                continue
            end

            ts, Is, last_good, nt = result

            if last_good < nt
                show(stdout, "text/markdown",
                     Markdown.parse("**$(symbol) shown over the first $(last_good) of $(nt) time steps: " *
                                    "at least one member of the ensemble crashed.**"))
                _linebreak(stdout)
            end

            _save_plot(() -> plot_invariant_error(ts, Is, symbol, headline),
                       plot_dir, file, suffix, fig_suff)

            _plot_figure_md(stdout, name, "$plot_dir/$file$suffix$fig_suff")
        end

        # One ensemble of a few hundred solutions per method, plus two figures; collecting them
        # here keeps the peak footprint within what a CI runner can hold.
        GC.gc()
    end

    nothing
end
