using Penning

const SIM_TIME = 0.001
const OVERSAMPLING = 20

U₀ = -50.0
c₂ = -14960.0
B₀ = 7.0

Re_ions = ParticleCollection(Ion(187, 30), SphericalHomogeneousParticleDistribution(10, 2e-5, 10))

omega_p = calc_omega_p(U₀, c₂, B₀, Re_ions.species.q, Re_ions.species.m)
omega_z = calc_omega_z(U₀, c₂, B₀, Re_ions.species.q, Re_ions.species.m)

trap = Trap(
    fields = (IdealTrapField(U₀, c₂, B₀),),
    particles = (Re_ions,)
)

setup = Setup(traps = (trap,))

dt = 2*pi/omega_p/OVERSAMPLING
sim = Simulation(setup, dt=dt, stop_time=SIM_TIME)

@time run!(sim)