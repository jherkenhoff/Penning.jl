using Penning
using Plots

const OVERSAMPLING = 20

const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 7.0

const D_eff = 5e-3
const R = 100e6


ion = Ion(187, 30)
omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, ion.q, ion.m)

# Theoretical damping time constant
d_theory = ion.q^2*R/ion.m/D_eff^2 / 2

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀),
    ),
    particles = (
        ParticleCollection(ion, [[0, 0, 50e-6]], [[0, 0, 0]]),
    ),
    electrodes = (
        AxialParallelPlateElectrode(D_eff),
    )
)

setup = Setup(
    traps = (
        trap,
    ),
    circuits = (
        SSCircuitResistor(R, T=0.0),
    ),
    connections = (
        Connection(trap=1, electrode=1, circuit=1, circuit_pin=1),
    )
)

sim = Simulation(
    setup, 
    dt=2*pi/omega_z/OVERSAMPLING,
    output_writers=(
        MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(4)),
    )
)

run!(sim, run_until_time=1/d_theory)

z = sim.output_writers[1].mem
t = sim.output_writers[1].t

plot(t, z)

harminv_results = harminv(t, z, omega_z/2/pi-10e3, omega_z/2/pi+10e3)

A = harminv_results[1].amp
d = harminv_results[1].decay_const
envelope = 2*A*exp.(-t*d)
plot!(t, envelope)

theory = 2*A*exp.(-t*d_theory)
plot!(t, theory)