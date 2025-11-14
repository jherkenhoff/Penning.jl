using Penning
using Penning.Constants

const N = 20

const U₀ = -20.0
const c₂ = -14960.0
const B₀ = 1.0

r₀ = [0, 0, 0]
r = spherical_homogeneous_positions(N, 100e-6, 30e-6, r₀)
v = rotating_spheroid_velocities(r, [0, 0, -2*π*100e3], r₀)

trap = Trap(
    particles = Particles(r, v, fill(30*q_e, N), fill(187*m_u, N)),
    fields = [
        IdealTrapField(U₀, c₂, B₀),
    ],
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
    particle_pusher = ModifiedBorisPusher(),
    output_writers = (
        VtkParticleWriter(
            "examples/output/particles",
            AllParticleSelection(setup),
            IterationInterval(100),
            observables = (
                V = VelocityObservable(),
                E = EFieldObservable()
            )
        ),
    )
)

run!(sim, WallTimeStopCondition(60))

finalize!(sim)