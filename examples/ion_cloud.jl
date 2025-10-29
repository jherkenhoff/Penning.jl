using Penning

const N = 10

const U₀ = 8.0
const c₂ = -14960.0
const B₀ = 1.0

r₀ = spherical_homogeneous_positions(N, 100e-6, 30e-6)
v₀ = rotating_spheroid_velocities(r₀, [0, 0, -2*π*100e3], [0, 0, 0])

trap = Trap(
    fields = [
        IdealTrapField(U₀, c₂, B₀),
    ],
    particles = (
        ParticleCollection(Electron(), r₀, v₀), # Ion(187, 30)
    ),
    interactions = [
        CoulombInteraction(),
    ]
)

setup = Setup(
    traps = (
        trap,
    )
)

sim = Simulation(
    setup,
    dt=2e-10,
    particle_pusher = BorisPusher(),
    output_writers = (
        VtkParticleWriter(
            "examples/output/particles",
            AllParticleSelection(setup),
            IterationInterval(1000),
            observables = (
                V = VelocityObservable(),
                E = EFieldObservable()
            )
        ),
    )
)

run!(sim, WallTimeStopCondition(20))

finalize!(sim)