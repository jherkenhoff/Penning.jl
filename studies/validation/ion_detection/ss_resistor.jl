using Penning
using Plots

const N_AXIAL_CYCLES = 60
const OVERSAMPLING = 20

const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 7.0

const R = 10e6

ion = Ion(187, 30)
omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, ion.q, ion.m)

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ParticleCollection(ion, [[0, 0, 0.5]], [[0, 0, 0]]),
    ),
    electrodes = (
        AxialParallelPlateElectrode(5e-3),
    )
)

setup = Setup(
    traps = (
        trap,
    ),
    circuit = SSCircuitResistor(R, T=4.2)
)

sim = Simulation(
    setup, 
    dt=2*pi/omega_p/OVERSAMPLING,
    output_writers=(
        MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(1)),
    )
)

run!(sim, run_until_time=2*pi/omega_z*N_AXIAL_CYCLES)

z = sim.output_writers[1].mem
t = sim.output_writers[1].t

plot(t, z)









R = 10000e6
@named resistor = Resistor(R=R)
@named ground = Ground()

connections = [
    connect(trap.electrodes[:axial].pin, resistor.p)
    connect(resistor.n, ground.g)
]
circuit = Circuit(connections, [trap.electrodes[:axial].pin, resistor, ground])

setup = Setup(circuit)
setup.traps[:trap] = trap

sim = Simulation(setup, dt=2*pi/omega_z(trap, species)/OVERSAMPLING, stop_time=2*pi/omega_z(trap, species)*N_AXIAL_CYCLES)
sim.diagnostics[:progress] = ProgressDiagnostic()
sim.output_writers[:memory_position] = PositionMemoryWriter(:trap, :particles, IterationInterval(1))

run!(sim)

using Plots
t = sim.output_writers[:memory_position].t
r_log = sim.output_writers[:memory_position].mem
z = [r[1][3] for r in r_log]
plot(t, z)

harminv_results = harminv(t, z, 10e3, 900e3)


A = harminv_results[1].amp
d = harminv_results[1].decay_const
envelope = 2*A*exp.(-t*d)
plot!(t, envelope)


d_theory = species.q^2*R/species.m/trap.electrodes[:axial].D[3]^2 / 2
theory = 2*A*exp.(-t*d_theory)
plot!(t, theory)