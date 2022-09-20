using GLMakie
using Printf

using Penning.Utils
using Penning.Setups
using Penning.Utils

struct DashboardDiagnostic <: AbstractDiagnostic
    schedule :: AbstractSchedule
    fig :: Figure
    total_energy :: Observable{Vector{Point2f}}
    supertitle :: Observable{String}
end

function DashboardDiagnostic(schedule::AbstractSchedule)
    fig = Figure()

    total_energy = Observable(Point2f[])

    #lines(fig[1,1], total_energy)

    ax_total_energy = Axis(fig[1, 1], title="Total Energy in Sim")

    supertitle = Observable("Iteration 0")
    Label(fig[0, :], text=supertitle)

    display(fig)

    return DashboardDiagnostic(schedule, fig, total_energy, supertitle)
end


function (diag::DashboardDiagnostic)(setup::Setup)
    diag.supertitle[] = @sprintf("Iteration: %d, time: %s ", setup.clock.iteration, prettytime(setup.clock.time))

    #push!(diag.total_energy[], Point2f([setup.clock.time, setup.trap_setups[:electron_trap].particle_collections[:electrons].r[1][3]]))
end

