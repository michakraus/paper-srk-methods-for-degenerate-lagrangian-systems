
using Logging
using Markdown
using Markdown: MD, Paragraph, LineBreak

using CairoMakie

using GeometricIntegrators
import GeometricIntegratorsBase
const GIB = GeometricIntegratorsBase
using SimpleSolvers: NonlinearSolverException

using GeometricProblems.Diagnostics: plot_energy_error, plot_energy_drift, plot_constraint_error


# Output directories for the figures (and, for symmetry with the SPARK companion package,
# the symplecticity conditions, which are not computed here).
const PLOT_DIR = "figures"
const SYMP_DIR = "symplecticity"


# Shared Makie plotting style (kept identical to the SPARK companion package). Larger
# fonts and thicker lines than the Makie defaults, tuned for the fixed figure sizes of
# the GeometricProblems plot recipes. Unicode axis labels are selected via `latex=false`
# on every plot call below.
# The theme is activated in the module's `__init__` (a `set_theme!` in the module body
# would only run during precompilation and have no effect at runtime).
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


# The degenerate Lagrangians make some of the methods diverge. The Newton solver then
# fails its line search in every iteration of every time step and `SimpleSolvers` emits
# one warning per failure: in the SPARK companion package this drowned a CI run in 173000
# of them, 99% of a 174583-line log. The warning cannot be switched off through the solver
# interface — `NewtonSolver` builds its `Linesearch` without forwarding the option
# keywords, so the line search always ends up with a default `Options` and
# `verbosity = 1` — hence we filter it out on the logging side instead, and likewise the
# equally repetitive tick warnings from the plotting stack. Only the count is reported, by
# `run_list`.
const QUIET_LOG_MODULES = (:SimpleSolvers, :PlotUtils, :Makie)
const QUIET_LOG_COUNT = Ref(0)

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

# Install the filter. Called by the weave driver, not on load, so that interactive
# sessions keep the warnings unless they ask for quiet.
quiet_solver_warnings!() = global_logger(QuietLogger(global_logger()))


# Integrate an IODE step-by-step so that a crash (solver failure, singular matrix,
# NaNs, …) does not discard the whole run: we keep the solution up to the last
# successful time step. Returns `(sol, last_good, err)` where `last_good` is the index
# of the last completed step and `err` is `nothing` (success), `:nan` (NaNs in the
# state), or the caught exception. The steps after `last_good` are padded with the last
# good state so downstream invariant computations never see uninitialized data.
function integrate_partial(iode, method)
    int     = GIB.GeometricIntegrator(iode, method; f_abstol=1E-14, f_reltol=1E-14, max_iterations=100)
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


# Short, human-readable one-line description of a crash (no stack trace).
function _failure_message(err)
    err === :nan                      && return "NaNs detected in the solution"
    err isa NonlinearSolverException  && return "solver error – " * err.msg
    err isa DomainError               && return "domain error"
    return string(nameof(typeof(err)))
end


# Reference a figure, but only if it was actually produced: a run that crashed early has
# no energy drift data, and one that crashed on the very first step has no figures at
# all. Referencing them regardless leaves broken images on the page and one
# `invalid local link/image` warning per figure in the Documenter build. Returns whether
# the reference was written.
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
    # intervals and its `nt` counts those intervals, not time steps. Show only the intervals
    # completed before a crash – and skip the plot unless at least two of them were
    # completed, as a single point has no drift to show and a degenerate x-range throws.
    # Solutions shorter than ten steps have no intervals at all and make the recipe itself
    # divide by zero, so they are skipped outright (short runs only happen in local tests).
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

        # DVRK wraps an inner tableau (e.g. DVRK(Gauss(1))); show it explicitly. All
        # other methods are shown as `Name(s)` (e.g. VPRKGauss(2), Gauss(2)).
        headline = method isa DVRK ?
            "DVRK($(tableau(method).name)($(tableau(method).s)))" :
            "$(nameof(typeof(method)))($(tableau(method).s))"

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

        # Each run leaves a set of Makie figures behind; collecting them here keeps the
        # peak footprint of a list of up to fifty methods within what a CI runner can hold.
        GC.gc()
    end

    if QUIET_LOG_COUNT[] > 0
        @info("Suppressed $(QUIET_LOG_COUNT[]) solver/plotting warnings so far (see QUIET_LOG_MODULES)")
    end

    nothing
end
