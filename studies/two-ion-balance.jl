using Penning

const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 1.0

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ion₁ = ParticleCollection(Ion(187, 30), [[50e-6, 0, 50e-6]], [[100, 0, 0]]),
        ion₂ = ParticleCollection(Ion(187, 30), [[-50e-6, 0, -50e-6]], [[-100, 0, 0]]),
    ),
    interactions = (
        CoulombInteraction(),
    )
)

setup = Setup(
    traps = (
        trap,
    )
)

sim = Simulation(
    setup,
    dt=20e-9,
    particle_pusher = BorisPusher(),
    output_writers = (
        VtkParticleWriter(
            "studies/data/particles",
            AllParticleSelection(setup),
            IterationInterval(1),
            observables = (
                V = VelocityObservable(),
                E = EFieldObservable()
            )
        ),
    )
)

run!(sim, run_until_time=10e-6)

finalize!(sim)