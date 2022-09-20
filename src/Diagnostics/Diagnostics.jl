module Diagnostics


export AbstractDiagnostic, ProgressDiagnostic, DashboardDiagnostic

abstract type AbstractDiagnostic end

include("progress.jl")
include("dashboard.jl")

end # module