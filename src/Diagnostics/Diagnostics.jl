module Diagnostics


export AbstractDiagnostic, ProgressDiagnostic

abstract type AbstractDiagnostic end

include("progress.jl")

end # module