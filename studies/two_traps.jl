using Penning

const N = 50
const SIM_TIME = 0.00001
const OVERSAMPLING = 20

const D_eff = 0.4e-3
const R = 10e6

U₀ = -50.0
c₂ = -14960.0
B₀ = 1.0

Re = Ion(187, 30)

omega_p = calc_omega_p(U₀, c₂, B₀, Re.q, Re.m)
omega_z = calc_omega_z(U₀, c₂, B₀, Re.q, Re.m)

trap1 = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (ParticleCollection(Re, SphericalHomogeneousParticleDistribution(N, 4e-4, 3000, r₀=[0, 0, 2e-4])),),
    #particles = (ParticleCollection(Re, SingleParticleDistribution([0, 0, 0], [0, 0, 0])),),
    interactions = ( CoulombInteraction(), ),
    electrodes = (AxialParallelPlateElectrode(D_eff),)
)

trap2 = Trap(
    fields = (IdealTrapField(U₀, c₂, B₀),),
    particles = (ParticleCollection(Re, SingleParticleDistribution([1e-4, 0, 0e-4], [0, 0, 0])),),
    electrodes = (AxialParallelPlateElectrode(D_eff),)
)

setup = Setup(
    traps = (trap1, trap2),
    circuit = SSCircuitResistor(R, T=0.0)
)

dt = 2*pi/omega_p/OVERSAMPLING
sim = Simulation(setup, 
    dt=dt,
    stop_time=SIM_TIME,
    output_writers = (
        VtkFieldWriter("studies/data/trapFieldA", 1, 1, VolumeExtractor(2e-3, n=10), SpecifiedTimes(0.0)),
        VtkFieldWriter("studies/data/trapFieldB", 2, 1, VolumeExtractor(2e-3, n=10), SpecifiedTimes(0.0)),
        VtkParticleWriter("studies/data/particlesA", 1, 1, IterationInterval(3)),
        VtkParticleWriter("studies/data/particlesB", 2, 1, IterationInterval(3)),
    )
)

@time run!(sim)