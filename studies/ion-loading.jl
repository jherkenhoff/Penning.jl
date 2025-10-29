using Penning
using Plots

const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 1.0

trap = Trap(
    fields = [
        IdealTrapField(U₀, c₂, B₀)
    ],
    particles = [
        ParticleCollection(Ion(187, 30), [[0, 0, -1e-3]], [[0, 0, 0]])
    ]
)

setup = Setup(
    traps = [trap]
)

sim = Simulation(
    setup,
    dt=20e-9,
    output_writers = [
        MemoryWriter(
            PositionObservable(),
            ParticleSelection(trap=1, particle_collection=1, particle_index=1),
            IterationInterval(1)
        )
    ]
)

run!(sim, run_until_time=10e-6)

r = sim.output_writers[1].mem
t = sim.output_writers[1].t

x = getindex.(r, 1)
y = getindex.(r, 2)
z = getindex.(r, 3)

plot(t*1e6, z*1e6, legend=false)
xlabel!("\$t\$ / ms")
ylabel!("Axial position / µm")
