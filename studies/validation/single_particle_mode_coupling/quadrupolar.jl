using Penning
using Plots

const OVERSAMPLING = 200
const N_AXIAL_CYCLES = 50

const A_rf = 100000

const U₀ = -50.0
const c₂ = -15000.0
const B₀ = 1.0

ion = Ion(187, 30)

omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(U₀, c₂, B₀, ion.q, ion.m)

trap = Trap(
    fields = (
        IdealTrapField(U₀, c₂, B₀), 
        QuadrupolarExcitationField(omega_p - omega_z, A_rf)
    ),
    particles = (
        ParticleCollection(ion, [[0, 0, 40e-6]], [[0, 0, 0]]),
    )
)

setup = Setup(
    traps = (trap, )
)

sim = Simulation(
    setup,
    dt=2*pi/omega_p/OVERSAMPLING,
    output_writers=(
        x = MemoryWriter(PositionComponentObservable(1, 1, 1, 1), IterationInterval(10)),
        z = MemoryWriter(PositionComponentObservable(1, 1, 1, 3), IterationInterval(10)),
    )
)

run!(sim, run_until_time=2*pi/omega_z*N_AXIAL_CYCLES)

# Theoretical Rabi frequency: (http://hdl.handle.net/21.11116/0000-0005-6361-E)(Page 25, equation 2.46)
Omega_R = A_rf/4*abs(ion.q) / ion.m /sqrt(omega_z*(omega_p-omega_m))
T_exchange = 2*pi/Omega_R/4
println("Theoretical exchange period: $T_exchange s")

t = sim.output_writers.z.t
z = sim.output_writers.z.mem
plot(t*1e6, z*1e6, labels="Simulated Z position")
vline!([T_exchange*1e6], labels="Theoretical pi pulse duration", plot_title="Sideband coupling")
xlabel!("Time / µs")
ylabel!("Axial amplitude / µm")

savefig(joinpath(@__DIR__, "quadrupolar.png"))