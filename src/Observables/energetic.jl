using LinearAlgebra
using Penning.Traps
using Penning.Electrodes
using Penning.Constants: e

struct SingleParticleTotalEnergy <: AbstractScalarObservable
    trap :: Symbol
    particle_collection :: Symbol
    particle_index :: Integer
end

function (obs::SingleParticleTotalEnergy)(setup::Setup)
    trap = setup.traps[obs.trap]
    q = trap.particles[obs.particle_collection].species.q
    m = trap.particles[obs.particle_collection].species.m

    r = trap.particles[obs.particle_collection].r[obs.particle_index]
    v = trap.particles[obs.particle_collection].v[obs.particle_index]

    PE_trap = calc_trap_PE(trap, r, q)
    if length(trap.electrodes) > 0
        PE_electrodes = sum([calc_electrode_PE(electrode, r, q) for electrode in values(trap.electrodes)])
    else
        PE_electrodes = 0.0
    end
    KE = 0.5*m*dot(v, v)
    return (PE_trap + PE_electrodes + KE)/e
end