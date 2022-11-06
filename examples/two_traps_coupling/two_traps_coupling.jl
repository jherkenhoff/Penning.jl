using Plots
using Penning

const AXIAL_CYCLES = 100
const OVERSAMPLING = 20

const B₀ = 1.0
const U₀ = -50.0
const c₂ = -14960.0

ion = Ion(187, 30)
omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, ion.q, ion.m)

trap1 = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ParticleCollection(ion, [[0.0, 0.0, 50.0e-6]], [[0.0, 0.0, 0.0]]),
    ),
    electrodes = (
        AxialParallelPlateElectrode(5e-3),
    )
)

trap2 = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ParticleCollection(ion, [[0.0, 0.0, 0.0]], [[0.0, 0.0, 0.0]]),
    ),
    electrodes = (
        AxialParallelPlateElectrode(5e-3),
    )
)

setup = Setup(
    traps = (
        trap1 = trap1,
        trap2 = trap2
    ),
    circuits = (
        #Resistor(10000e6),
        Capacitor(1e-17),
    ),
    circuit_connections = (
        CircuitConnection(ElectrodeSelection(trap=:trap1, electrode=1), CircuitPinSelection(circuit=1, pin=1)),
        CircuitConnection(ElectrodeSelection(trap=:trap2, electrode=1), CircuitPinSelection(circuit=1, pin=1))
    )
)

dt = 2*pi/omega_z / OVERSAMPLING
sim = Simulation(
    setup,
    dt=dt,
    output_writers = (
        z_1 = MemoryWriter(
            VectorComponentObservable(PositionObservable(), :z),
            ParticleSelection(trap=:trap1, particle_collection=1, particle_index=1),
            IterationInterval(1)
        ),
        z_2 = MemoryWriter(
            VectorComponentObservable(PositionObservable(), :z),
            ParticleSelection(trap=:trap2, particle_collection=1, particle_index=1),
            IterationInterval(1)
        ),
        U = MemoryWriter(
            CircuitPinVoltageObservable(),
            CircuitPinSelection(circuit=1, pin=1),
            IterationInterval(1)
        ),
    )
)

run!(sim, run_until_time=2*pi/omega_z*AXIAL_CYCLES)

finalize!(sim)


t = sim.output_writers[:z_1].t
z_1 = sim.output_writers[:z_1].mem
z_2 = sim.output_writers[:z_2].mem
U = sim.output_writers[:U].mem

plot(t, z_2)
