using Penning

const N = 100
const SIM_TIME = 0.001
const OVERSAMPLING = 40

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
    particles = (ParticleCollection(Re, cubic_homogeneous_positions(N, 6e-4), boltzman_velocities(N, 4.2)),),
    interactions = ( CoulombInteraction(), ),
)


setup = Setup(
    traps = (trap1, ),
)

dt = 2*pi/omega_p/OVERSAMPLING
sim = Simulation(setup, 
    dt=dt,
    stop_time=SIM_TIME,
    #output_writers = (
     #   VtkParticleWriter("studies/data/particles", 1, 1, IterationInterval(1)),
    #)
)

@time run!(sim)
