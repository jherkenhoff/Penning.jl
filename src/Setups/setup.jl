using Penning.Traps
using Penning.Particles
using Penning.Circuits

import Penning.Common

struct Setup{T, CIR, CON}
    traps :: T
    circuits :: CIR
    circuit_connections :: CON
    clock :: Clock
end

function Setup(; traps, circuits=(;), circuit_connections=(;))
    clock = Clock()
    # TODO: Check that an electrode is only connected to at most one circuit
    return Setup(traps, circuits, circuit_connections, clock)
end

function Common.reset!(setup::Setup)
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