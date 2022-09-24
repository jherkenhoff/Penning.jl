using Penning
using Plots

const OVERSAMPLING = 200
const N_AXIAL_CYCLES = 50

const U₀ = -50.0
const c₂ = -15000.0
const B₀ = 1.0

const E₀ = 10000.0

ion = Ion(187, 30)

omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, ion.q, ion.m)

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
        PlaneWaveExcitationField(omega_p - omega_z - 1e3, E₀)
    ),
    particles = (
        ParticleCollection(ion, [[0, 0, 0]], [[0, 0, 0]]),
    )
)

setup = Setup(
    traps = (trap, )
)

sim = Simulation(
    setup,
    dt=2*pi/omega_p/OVERSAMPLING,
    output_writers=(
        x = MemoryWriter(PositionComponentObservable(1, 1, 1, 1), IterationInterval(1)),
        z = MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(10)),
    )
)

run!(sim, run_until_time=2*pi/omega_z*N_AXIAL_CYCLES)

t = sim.output_writers.z.t
z = sim.output_writers.z.mem
#t = sim.output_writers.x.t
#x = sim.output_writers.x.mem
plot(t*1e6, z*1e6, labels="Simulated Z position")
xlabel!("Time / µs")
ylabel!("Axial amplitude / µm")

#savefig(joinpath(@__DIR__, "plane_wave.png"))