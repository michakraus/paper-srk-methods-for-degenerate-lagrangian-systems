
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


function _plot_figure_md(file, name, filename)
    # if isfile(filename)
        show(file, "text/markdown", Markdown.parse("![$name]($filename)"))
        _linebreak(file)
    # else
    #     show(stdout, "text/markdown", Markdown.parse("ERROR: Plot output $filename does not exist!"))
    #     @warn("Plot output $filename does not exist!")
    # end
end


function write_plots(dir, file, name, fig_suff)

    plot_file = file * ".md"

    open(plot_file, "w") do f
        show(f, "text/markdown", Markdown.parse("# $name"))
        _linebreak(f)

        _plot_figure_md(f, name, "$(dir)/$(file)_solution$(fig_suff)")
        _plot_figure_md(f, name, "$(dir)/$(file)_traces$(fig_suff)")

        show(f, "text/markdown", Markdown.parse("## Energy Error"))
        _linebreak(f)

        _plot_figure_md(f, name, "$(dir)/$(file)_energy_error$(fig_suff)")
        _plot_figure_md(f, name, "$(dir)/$(file)_energy_drift$(fig_suff)")

        show(f, "text/markdown", Markdown.parse("## Constraint"))
        _linebreak(f)

        _plot_figure_md(f, name, "$(dir)/$(file)_constraint_error$(fig_suff)")
    end
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
    interval = max(div(nt, 10), 1)
    ntdrift  = last_good ≥ nt ? (:auto) : div(last_good, interval)

    if ntdrift === :auto || ntdrift ≥ 2
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

        write_plots(plot_dir, file, name, fig_suff)

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
        show(stdout, "text/markdown", Markdown.parse("![$name]($plot_dir/$file$fig_suff)"))
    end

    nothing
end
