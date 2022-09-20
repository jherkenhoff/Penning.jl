using ModelingToolkit, DifferentialEquations
using Plots
using FFTW

using Penning

const N_AXIAL_CYCLES = 10000
const OVERSAMPLING = 20

const SAVE_OVERSAMPLING = 4

species = Ion(187, 30)
particle_distribution = SingleParticleDistribution([0, 0, 0], [0, 0, 0]) # No radial displacement or velocity. We only want to simulate axial motion
particles = ParticleCollection(species, particle_distribution)

trap = IdealTrap(-50.0, -14960.0, 7.0)
trap.particles[:particles] = particles
trap.electrodes[:axial] = AxialParallelPlateElectrode(5e-3)

R = 100e6
@named resistor = NoisyResistor(R=R, T=4.2)
@named ground = Ground()

connections = [
    connect(trap.electrodes[:axial].pin, resistor.p)
    connect(resistor.n, ground.g)
]
circuit = Circuit(connections, [trap.electrodes[:axial].pin, resistor, ground])

setup = Setup(circuit)
setup.traps[:trap] = trap

sim = Simulation(setup, dt=2*pi/omega_z(trap, species)/OVERSAMPLING, stop_iteration=N_AXIAL_CYCLES*OVERSAMPLING)
sim.output_writers[:resistor_v] = CircuitMemoryWriter(resistor.v, IterationInterval(OVERSAMPLING/SAVE_OVERSAMPLING))
sim.output_writers[:memory_position] = PositionMemoryWriter(:trap, :particles, IterationInterval(OVERSAMPLING/SAVE_OVERSAMPLING))


run!(sim)

t = Vector{Float64}(sim.output_writers[:resistor_v].t)
v = Vector{Float64}(sim.output_writers[:resistor_v].mem)
z = [r[1][3] for r in sim.output_writers[:memory_position].mem]

plot(t, z)

fft_v = rfft(v)
fft_f = LinRange(0.0, 1/(t[2]-t[1])/2, length(fft_v))
plot(fft_f, 20*log10.(abs.(fft_v)))
#vline!([omega_z(trap, species)/2/pi], labels="Theoretical axial frequency")
xlims!((720e3, 800e3))