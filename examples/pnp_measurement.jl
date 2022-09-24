using Penning
using Plots

const N_AXIAL_CYCLES = 10
const OVERSAMPLING = 200

const U₀ = -50.0
const c₂ = -15000.0
const B₀ = 1.0

ion = ParticleCollection(Ion(187, 30), [[0, 0, 0.5]], [[1000, 0, 0]])

omega_m_theory = calc_omega_m(U₀, c₂, B₀, ion.species.q, ion.species.m)
omega_p_theory = calc_omega_p(U₀, c₂, B₀, ion.species.q, ion.species.m)
omega_z_theory = calc_omega_z(U₀, c₂, B₀, ion.species.q, ion.species.m)

trap = Trap(
    fields = (IdealTrapField(U₀, c₂, B₀), ),
    particles = (ion, )
)

setup = Setup(
    traps = (trap, )
)

dt = 2*pi/omega_p/OVERSAMPLING
sim = Simulation(
    setup,
    dt=dt,
    output_writers=(
        x = MemoryWriter(PositionComponentObservable(1, 1, 1, 1), IterationInterval(1)),
        z = MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(1)),
    )
)

run!(sim, run_until_time=2*pi/omega_z*N_AXIAL_CYCLES)

x_harminv_results = harminv(sim.output_writers.x.t, sim.output_writers.x.mem, omega_m/2/pi/2, omega_p/2/pi*2)
z_harminv_results = harminv(sim.output_writers.z.t, sim.output_writers.z.mem, omega_z/2/pi-10e3, omega_z/2/pi+10e3)

omega_z = z_harminv_results[1].f*2*pi
omega_m = x_harminv_results[1].f*2*pi
omega_p = x_harminv_results[2].f*2*pi

@info "Found axial frequency at $(omega_z/2/pi/1e3) kHz ($((omega_z-omega_z_theory)/2/pi) Hz deviation from theory)"
@info "Found magnetron frequency at $(omega_m/2/pi/1e3) kHz ($((omega_m-omega_m_theory)/2/pi) Hz deviation from theory)"
@info "Found cyclotron frequency at $(omega_p/2/pi/1e3) kHz ($((omega_p-omega_p_theory)/2/pi) Hz deviation from theory)"
