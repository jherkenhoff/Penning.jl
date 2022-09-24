using Penning
using Plots

const N_AXIAL_CYCLES = 10
const OVERSAMPLING = 20

const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 7.0

ion = Ion(187, 30)
omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, ion.q, ion.m)

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ParticleCollection(ion, [[0, 0, 0.5]], [[1000, 0, 0]]),
    )
)

setup = Setup(
    traps = (
        trap,
    )
)

dt = 2*pi/omega_p/OVERSAMPLING
sim = Simulation(
    setup, 
    dt=dt,
    output_writers=(
        MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(1)),
    )
)

run!(sim, run_until_time=2*pi/omega_z*N_AXIAL_CYCLES)

z = sim.output_writers[1].mem
t = sim.output_writers[1].t

plot(t, z)