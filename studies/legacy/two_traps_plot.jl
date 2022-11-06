using Penning
using Plots

const N = 50
const SIM_TIME = 0.001
const OVERSAMPLING = 20

const D_eff = 0.4e-3
const R = 100e6

U₀ = -50.0
c₂ = -14960.0
B₀ = 1.0

Re = Ion(187, 30)

omega_p = calc_omega_p(U₀, c₂, B₀, Re.q, Re.m)
omega_z = calc_omega_z(U₀, c₂, B₀, Re.q, Re.m)

trap1 = Trap(
    fields = (IdealTrapField(U₀, c₂, B₀),),
    particles = (ParticleCollection(Re, SingleParticleDistribution([0, 0, 0], [0, 0, 0])),),
    interactions = ( CoulombInteraction(), ),
    electrodes = (AxialParallelPlateElectrode(D_eff),)
)

trap2 = Trap(
    fields = (IdealTrapField(U₀, c₂, B₀),),
    particles = (ParticleCollection(Re, SingleParticleDistribution([0, 0, 2e-4], [0, 0, 0])),),
    electrodes = (AxialParallelPlateElectrode(D_eff),)
)

setup = Setup(
    traps = (trap1, trap2),
    circuit = SSCircuitResistor(R, T=0.0)
)

dt = 2*pi/omega_z/OVERSAMPLING
sim = Simulation(setup, 
    dt=dt,
    stop_time=SIM_TIME,
    output_writers = (
        MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(1)),
        MemoryWriter(PositionComponentObservable(2, 1, 1, 3), IterationInterval(1)),
    )
)

@time run!(sim)


z1 = sim.output_writers[1].mem
z2 = sim.output_writers[2].mem

plot(z1)