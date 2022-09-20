using ModelingToolkit, DifferentialEquations
using Plots
using FFTW

using Penning

OVERSAMPLING = 20
const SAMPLES_PER_CYCLE = 2000
const N_AVERAGES=100
const IGNORE_FIRST_N_AVERAGES = 30

R = 100e6
L = 4.32e-3
C = 10e-12
@named resistor = NoisyResistor(R=R, T=4.2)
@named inductor = Inductor(L=L)
@named capacitor = Capacitor(C=C)
@named ground = Ground()

connections = [
    connect(resistor.p, inductor.p, capacitor.p)
    connect(resistor.n, inductor.n, capacitor.n, ground.g)
]
circuit = Circuit(connections, [resistor, inductor, capacitor, ground])

setup = Setup(circuit)

omega_res = 1/sqrt(C*L)
println("Theoretical resonance frequency: $(omega_res/2/pi/1e3) kHz")

sim = Simulation(setup, dt=2*pi/omega_res/OVERSAMPLING, stop_iteration=SAMPLES_PER_CYCLE)
sim.output_writers[:resistor_v] = CircuitMemoryWriter(resistor.v, IterationInterval(1))

fft_v = zeros(Float64, floor(Int, SAMPLES_PER_CYCLE/2+1))
fft_f = LinRange(0.0, 1/sim.dt/2, floor(Int, SAMPLES_PER_CYCLE/2+1))

for i in 1:(N_AVERAGES+IGNORE_FIRST_N_AVERAGES)
    @info "Average cycle $i"

    reset!(sim)
    run!(sim)

    if i >= IGNORE_FIRST_N_AVERAGES
        v = Vector{Float64}(sim.output_writers[:resistor_v].mem)
        
        fft_v .+= 20*log10.(abs.(rfft(v)))
    end
end

fft_v .= fft_v./N_AVERAGES

plot(fft_f, fft_v)
vline!([omega_z(trap, species)/2/pi], labels="Theoretical axial frequency")
#xlims!((500e3, 900e3))