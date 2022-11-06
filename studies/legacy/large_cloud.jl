using Penning

const N = 300
const SIM_TIME = 0.001
const OVERSAMPLING = 20

const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 1.0

Re = Ion(187, 30)

omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, Re.q, Re.m)

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ParticleCollection(Re, spherical_homogeneous_positions(N, 10e-4), boltzman_velocities(N, 2000.2)),
    ),
    interactions = (
        CoulombInteraction(),
    ),
    electrodes = (
        AxialParallelPlateElectrode(5e-3),
    )
)

setup = Setup(
    traps = (
        trap,
    ),
    circuits = (
        CircuitResistor(100e6),
    ),
    circuit_connections = (
        CircuitConnection(ElectrodeSelection(trap=1, electrode=1), CircuitPinSelection(circuit=1, pin=1)),
    )
)

dt = 2*pi/omega_c / OVERSAMPLING
sim = Simulation(
    setup,
    dt=dt,
    output_writers = (
        VtkParticleWriter(
            "studies/data/particles",
            AllParticleSelection(setup),
            IterationInterval(1),
            observables = (
                V = VelocityObservable(),
                E = EFieldObservable(),
                KE = KineticEnergyObservable(),
                V_mag = VectorNormObservable(VelocityObservable())
            )
        ),
    )
)

run!(sim, run_until_time=10e-6)

finalize!(sim)
