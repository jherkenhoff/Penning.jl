using ModelingToolkit, DifferentialEquations
using Plots
using FFTW

using Penning

const N_AXIAL_CYCLES = 1000
const OVERSAMPLING = 20
const N_AVERAGES = 1
const IGNORE_FIRST_N_AVERAGES = 0
const SAVE_OVERSAMPLING = 4

const A_rf = 0

species = Ion(187, 30)
particle_distribution = SingleParticleDistribution([0, 0, 1e-6], [0, 0, 0]) # No radial displacement or velocity. We only want to simulate axial motion
particles = ParticleCollection(species, particle_distribution)

trap = IdealTrap(-49.63, -14960.0, 7.0)
trap.particles[:particles] = particles
trap.electrodes[:axial] = AxialParallelPlateElectrode(0.4e-3)
trap.excitations[:quadrupolar] = QuadrupolarExcitation(omega_p(trap, species) - omega_z(trap, species), A_rf)

R = 10e6
L = 4.32e-3
C = 10e-12
omega_res = 1/sqrt(C*L)
@named resistor = NoisyResistor(R=R, T=4.2)
@named inductor = Inductor(L=L)
@named capacitor = Capacitor(C=C)
@named ground = Ground()

connections = [
    connect(trap.electrodes[:axial].pin, resistor.p, inductor.p, capacitor.p)
    connect(resistor.n, inductor.n, capacitor.n, ground.g)
]
circuit = Circuit(connections, [trap.electrodes[:axial].pin, resistor, inductor, capacitor, ground])

setup = Setup(circuit)
setup.traps[:trap] = trap

sim = Simulation(setup, dt=2*pi/omega_z(trap, species)/OVERSAMPLING, stop_iteration=N_AXIAL_CYCLES*OVERSAMPLING)
sim.diagnostics[:progress] = ProgressDiagnostic()
sim.output_writers[:resistor_v] = CircuitMemoryWriter(resistor.v, IterationInterval(OVERSAMPLING/SAVE_OVERSAMPLING))
sim.output_writers[:memory_position] = PositionMemoryWriter(:trap, :particles, IterationInterval(OVERSAMPLING/SAVE_OVERSAMPLING))

fft_v = zeros(Float64, floor(Int, N_AXIAL_CYCLES*SAVE_OVERSAMPLING/2+1))
fft_f = LinRange(0.0, 1/(sim.dt*OVERSAMPLING/SAVE_OVERSAMPLING)/2, length(fft_v))

for i in 1:(N_AVERAGES+IGNORE_FIRST_N_AVERAGES)
    @info "Average cycle $i"

    reset!(sim)
    run!(sim)

    if i > IGNORE_FIRST_N_AVERAGES
        v = Vector{Float64}(sim.output_writers[:resistor_v].mem)
        
        fft_v .+= 20*log10.(abs.(rfft(v)))
    end
end
z = [r[1][3] for r in sim.output_writers[:memory_position].mem]

const SPAN = 40e3

fft_z = rfft(z)
plot(fft_f/1e3, 20*log10.(abs.(fft_z)))
xlims!((omega_res/2/pi-SPAN/2, omega_res/2/pi+SPAN/2)./1e3)

fft_v .= fft_v./N_AVERAGES

plot(fft_f/1e3, fft_v, labels="Simulated resonator voltage", plot_title="Dip of 187Re30+")
xlims!((omega_res/2/pi-SPAN/2, omega_res/2/pi+SPAN/2)./1e3)
ylims!((-80, -25))
xlabel!("Frequency / kHz")

#savefig(joinpath(@__DIR__, "resonator_double_dip.png"))