using Penning

const N = 50
const SIM_TIME = 0.00001
const OVERSAMPLING = 20

U₀ = -50.0
c₂ = -14960.0
B₀ = 1.0

Re_ions = ParticleCollection(Ion(187, 30), SphericalHomogeneousParticleDistribution(N, 5e-4, 3000))

omega_p = calc_omega_p(U₀, c₂, B₀, Re_ions.species.q, Re_ions.species.m)
omega_z = calc_omega_z(U₀, c₂, B₀, Re_ions.species.q, Re_ions.species.m)

trap = Trap(
    fields = (IdealTrapField(U₀, c₂, B₀),),
    particles = (Re_ions,),
    interactions = ( CoulombInteraction(), )
)

setup = Setup(traps = (trap,))

dt = 2*pi/omega_p/OVERSAMPLING
sim = Simulation(setup, 
    dt=dt,
    stop_time=SIM_TIME,
    output_writers = (VtkParticleWriter("studies/data/particles", 1, 1, IterationInterval(1)),)
)

@time run!(sim)