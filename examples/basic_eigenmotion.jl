using Penning
using Plots

const N_AXIAL_CYCLES = 10
const OVERSAMPLING = 20

U₀ = -50.0
c₂ = -14960.0
B₀ = 7.0

Re_ions = ParticleCollection(Ion(187, 30), [[0, 0, 0.5]], [[1000, 0, 0]])

omega_p = calc_omega_p(U₀, c₂, B₀, Re_ions.species.q, Re_ions.species.m)
omega_z = calc_omega_z(U₀, c₂, B₀, Re_ions.species.q, Re_ions.species.m)

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        Re_ions,
    )
)

setup = Setup(
    traps = (
        trap,
    )
)

dt = 2*pi/omega_p/OVERSAMPLING
sim = Simulation(setup, 
    dt=dt, 
    output_writers=(MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(1)),),
    stop_time=2*pi/omega_z*N_AXIAL_CYCLES)

run!(sim)

z = sim.output_writers[1].mem
t = sim.output_writers[1].t

plot(t, z)