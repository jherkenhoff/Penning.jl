using Penning.Setups
using Penning.Fields
using Penning.Particles
using Penning.Traps
using Penning.Simulations
using Penning.OutputWriters
using Penning.Observables
using Penning.Utils

function find_eigenfreqs(U₀, c₂, B₀, species, oversamping; n_axial_cycles=10)

    omega_c_theory, omega_p_theory, omega_m_theory, omega_z_theory = calc_eigenfrequencies(U₀, c₂, B₀, species.q, species.m)

    trap = Trap(
        fields = (IdealTrapField(U₀, c₂, B₀), ),
        particles = (ParticleCollection(species, [[0, 0, 50e-6]], [[1000, 0, 0]]), )
    )
    
    setup = Setup(
        traps = (trap, )
    )
    
    dt = 2*pi/omega_p_theory/oversamping
    sim = Simulation(
        setup,
        dt=dt,
        output_writers=(
            x = MemoryWriter(PositionComponentObservable(1, 1, 1, 1), IterationInterval(1)),
            z = MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(1)),
        )
    )
    
    run!(sim, run_until_time=2*pi/omega_z_theory*n_axial_cycles)
    
    x_harminv_results = harminv(sim.output_writers.x.t, sim.output_writers.x.mem, omega_m_theory/2/pi/2, omega_p_theory/2/pi*2)
    z_harminv_results = harminv(sim.output_writers.z.t, sim.output_writers.z.mem, omega_z_theory/2/pi-10e3, omega_z_theory/2/pi+10e3)
    
    omega_p = x_harminv_results[2].f*2*pi
    omega_m = x_harminv_results[1].f*2*pi
    omega_z = z_harminv_results[1].f*2*pi

    return omega_p, omega_m, omega_z
end

