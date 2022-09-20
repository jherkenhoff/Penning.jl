using Penning.Traps
using Penning.Particles
using Penning.Circuits

import Penning

mutable struct Setup{T}
    traps :: T
    circuit :: Union{AbstractCircuit, Nothing}
    clock :: Clock
end

function Setup(; traps, circuit=nothing)
    clock = Clock()
    return Setup(traps, circuit, clock)
end

function Setup(circuit::AbstractCircuit; traps)
    clock = Clock()
    return Setup(traps, circuit, clock)
end

function Penning.reset!(setup::Setup)
    reset!(setup.clock)
end

function Base.summary(s::Setup)
    N_traps = length(s.traps)
    if N_traps == 1
        return string("Setup with $N_traps trap")
    else
        return string("Setup with $N_traps traps")
    end
end