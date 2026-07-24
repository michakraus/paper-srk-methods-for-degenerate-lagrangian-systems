
using Markdown
using Markdown: MD, Paragraph, LineBreak

using CairoMakie

using GeometricIntegrators
import GeometricIntegratorsBase
const GIB = GeometricIntegratorsBase
using SimpleSolvers: NonlinearSolverException

using GeometricProblems.LotkaVolterra2d: plot_solution, plot_phase_portrait, plot_traces
using GeometricProblems.Diagnostics: plot_energy_error, plot_energy_drift, plot_constraint_error


# Shared Makie plotting style (kept identical to the SPARK companion package). Larger
# fonts and thicker lines than the Makie defaults, tuned for the fixed figure sizes of
# the GeometricProblems plot recipes. Unicode axis labels are selected via `latex=false`
# on every plot call below.
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

set_theme!(PLOT_THEME)


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


# Plot the solution up to time step `last_good` (`:auto` plots the whole solution). All
# time-trace panels are limited to `last_good` and share the full-tspan x-axis, so a
# partial run shows its trajectory up to the crash within the complete time interval.
function make_plots(sol, equ, dir, file, fig_suff, last_good)
    if !isdir(dir)
        mkdir(dir)
    end

    nt      = ntime(sol)
    ntplot  = last_good ≥ nt ? (:auto) : last_good

    try
        # All GeometricProblems recipes set their own x-limits to the plotted time
        # range, so no post-processing is needed here.
        save(dir * "/" * file * fig_suff, plot_solution(sol, equ; latex=false, nt=ntplot))
        save(dir * "/" * file * "_solution" * fig_suff, plot_phase_portrait(sol; latex=false, nt=ntplot))
        save(dir * "/" * file * "_traces" * fig_suff, plot_traces(sol, equ; latex=false, nt=ntplot))

        save(dir * "/" * file * "_energy_error" * fig_suff, plot_energy_error(sol; latex=false, nt=ntplot))

        # Drift is an interval-based diagnostic; only show the intervals before the crash.
        ntdrift = last_good ≥ nt ? (:auto) : div(last_good, div(nt, 10))
        save(dir * "/" * file * "_energy_drift" * fig_suff, plot_energy_drift(sol; latex=false, nt=ntdrift))

        save(dir * "/" * file * "_constraint_error" * fig_suff, plot_constraint_error(sol; latex=false, nt=ntplot))
    catch ex
        show(stdout, "text/markdown", Markdown.parse("**Plotting failed: $(_failure_message(ex)).**"))
        _linebreak(stdout)
        @warn("Plotting failed: $(_failure_message(ex))")
    end
end


function run_integrator(iode, method, dir, file, fig_suff)
    sol, last_good, err = integrate_partial(iode, method)

    if err !== nothing
        show(stdout, "text/markdown",
             Markdown.parse("**Simulation crashed after $(last_good) of $(ntime(sol)) time steps: $(_failure_message(err)).**"))
        _linebreak(stdout)
        @warn("Simulation crashed after $(last_good) of $(ntime(sol)) time steps: $(_failure_message(err))")
    end

    # Plot whatever was computed (the trajectory up to the last successful step).
    if last_good ≥ 1
        make_plots(sol, iode, dir, file, fig_suff, last_good)
    end
end


function run_list(iode, name, list, plot_dir = PLOT_DIR, symp_dir = SYMP_DIR;
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

        run_integrator(iode, method, plot_dir, file, fig_suff)
        show(stdout, "text/markdown", Markdown.parse("![$name]($plot_dir/$file$fig_suff)"))
    end

    nothing
end
