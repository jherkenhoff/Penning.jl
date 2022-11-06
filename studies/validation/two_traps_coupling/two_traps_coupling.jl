using Plots
using Penning

const AXIAL_CYCLES = 10000
const OVERSAMPLING = 20

const B₀ = 1.0
const U₀ = -50.0
const c₂ = -14960.0

const D_eff = 5e-3

const C = 1e-15

const ion = Ion(187, 30)
const omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, ion.q, ion.m)

# Calculate theoretical energy exchange frequency (Rabi frequency):
Ωᵣ = ion.q^2/omega_z/D_eff^2/C/ion.m
T_exchange = pi/Ωᵣ
println("Theoretical Rabi frequency: $(Ωᵣ/2/pi) Hz")
println("Theoretical exchange period: $(pi/Ωᵣ) s")

trap1 = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ParticleCollection(ion, [[0.0, 0.0, 50.0e-6]], [[0.0, 0.0, 0.0]]),
    ),
    electrodes = (
        AxialParallelPlateElectrode(D_eff),
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
        AxialParallelPlateElectrode(D_eff),
    )
)

setup = Setup(
    traps = (
        trap1 = trap1,
        trap2 = trap2
    ),
    circuits = (
        #Resistor(100e6),
        Capacitor(C),
    ),
    circuit_connections = (
        CircuitConnection(ElectrodeSelection(trap=:trap1, electrode=1), CircuitPinSelection(circuit=1, pin=1)),
        CircuitConnection(ElectrodeSelection(trap=:trap2, electrode=1), CircuitPinSelection(circuit=1, pin=1))
    )
)

dt = 2*pi/omega_z/OVERSAMPLING
sim = Simulation(
    setup,
    dt=dt,
    output_writers = (
        z_1 = MemoryWriter(
            VectorComponentObservable(PositionObservable(), :z),
            ParticleSelection(trap=:trap1, particle_collection=1, particle_index=1),
            IterationInterval(51)
        ),
        z_2 = MemoryWriter(
            VectorComponentObservable(PositionObservable(), :z),
            ParticleSelection(trap=:trap2, particle_collection=1, particle_index=1),
            IterationInterval(51)
        )
    )
)

run!(sim, run_until_time=2*pi/omega_z*AXIAL_CYCLES)

finalize!(sim)

t = sim.output_writers[:z_1].t
z_1 = sim.output_writers[:z_1].mem
z_2 = sim.output_writers[:z_2].mem

plot(t*1e3, z_1, label="Ion 1")
plot!(t*1e3, z_2, label="Ion 2")
xlabel!("Time / ms")
vline!([T_exchange*1e3], labels="Theoretical Rabi period")
