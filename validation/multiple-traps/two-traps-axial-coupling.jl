using ModelingToolkit, DifferentialEquations
using Plots

using Penning

const N_AXIAL_CYCLES = 5000
const OVERSAMPLING = 20
const D_eff = 0.7e-3

species = Ion(187, 30)

trap_1 = IdealTrap(-49.63, -14960.0, 7.0)
trap_1.particles[:particles] = ParticleCollection(species, SingleParticleDistribution([0, 0, 1e-6], [0, 0, 0]))
trap_1.electrodes[:axial] = AxialParallelPlateElectrode(D_eff)

trap_2 = IdealTrap(-49.63, -14960.0, 7.0)
trap_2.particles[:particles] = ParticleCollection(species, SingleParticleDistribution([0, 0, -1e-6], [0, 0, 0]))
trap_2.electrodes[:axial] = AxialParallelPlateElectrode(D_eff)

R = 10e6
@named resistor = Resistor(R=R)
@named ground = Ground()

connections = [
    connect(trap_1.electrodes[:axial].pin, trap_2.electrodes[:axial].pin, resistor.p),
    connect(resistor.n, ground.g)
]
circuit = Circuit(connections, [trap_1.electrodes[:axial].pin, trap_2.electrodes[:axial].pin, resistor, ground])

setup = Setup(circuit)
setup.traps[:trap_1] = trap_1
setup.traps[:trap_2] = trap_2

sim = Simulation(setup, dt=2*pi/omega_z(trap_1, species)/OVERSAMPLING, stop_iteration=N_AXIAL_CYCLES*OVERSAMPLING)
sim.output_writers[:resistor_v] = CircuitMemoryWriter(resistor.v, IterationInterval(1))
sim.output_writers[:trap_1_position] = PositionMemoryWriter(:trap_1, :particles, IterationInterval(1))
sim.output_writers[:trap_2_position] = PositionMemoryWriter(:trap_2, :particles, IterationInterval(1))

run!(sim)

z1 = [r[1][3] for r in sim.output_writers[:trap_1_position].mem]
z2 = [r[1][3] for r in sim.output_writers[:trap_2_position].mem]

plot(z2)