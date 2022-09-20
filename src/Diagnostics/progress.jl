using Printf

using Penning.Setups
using Penning.Utils

struct ProgressDiagnostic <: AbstractDiagnostic
    schedule :: AbstractSchedule
end

function ProgressDiagnostic(; wall_time_interval=3.0)
    return ProgressDiagnostic(WallTimeInterval(wall_time_interval))
end

function (diag::ProgressDiagnostic)(setup::Setup)
    @printf("i: % 6d, sim time: %10s\n", setup.clock.iteration , prettytime(setup.clock.time))
end