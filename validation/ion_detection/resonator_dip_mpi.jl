
using ModelingToolkit, DifferentialEquations
using Plots
using FFTW
using MPI
using Penning

const ROOT = 0

const N_AXIAL_CYCLES = 10000
const OVERSAMPLING = 20
const N_AVERAGES = 5
const SAVE_OVERSAMPLING = 4
const Z_INIT_MAX = 1e-6

const R = 10e6
const L = 4.32e-3
const C = 10e-12
const omega_res = 1/sqrt(C*L)

MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
comm_size = MPI.Comm_size(comm)

function split_count(N::Integer, n::Integer)
    q,r = divrem(N, n)
    return [i <= r ? q+1 : q for i = 1:n]
end

if rank == ROOT
    println("Running on $(comm_size) MPI processes")

    N_all = split_count(N_AVERAGES, comm_size)
end

RN_local = Ref{Int}()
MPI.Scatter!(rank == 0 ? N_all : nothing, RN_local, ROOT, comm)
N_local = RN_local[]

if rank == ROOT
    z_start_all = rand(N_AVERAGES)*Z_INIT_MAX
end
z_start_local = zeros(N_local)

MPI.Scatterv!(rank == 0 ? VBuffer(z_start_all, N_all) : nothing, z_start_local, ROOT, comm)

fft_v = zeros(Float64, floor(Int, N_AXIAL_CYCLES*SAVE_OVERSAMPLING/2+1))

for z_start in z_start_local
    species = Ion(187, 30)
    particle_distribution = SingleParticleDistribution([0, 0, z_start], [0, 0, 0])
    particles = ParticleCollection(species, particle_distribution)

    trap = IdealTrap(-49.63, -14960.0, 7.0)
    trap.particles[:particles] = particles
    trap.electrodes[:axial] = AxialParallelPlateElectrode(0.4e-3)

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
    sim.output_writers[:resistor_v] = CircuitMemoryWriter(resistor.v, IterationInterval(OVERSAMPLING/SAVE_OVERSAMPLING))

    run!(sim)

    v = Vector{Float64}(sim.output_writers[:resistor_v].mem)
    fft_v .+= 20*log10.(abs.(rfft(v)))
end


MPI.Reduce!(fft_v, MPI.SUM, ROOT, comm)
#(x,y) -> x.+y

if rank == ROOT
    fft_v .= fft_v ./ N_AVERAGES

    trap = IdealTrap(-49.63, -14960.0, 7.0)
    species = Ion(187, 30)
    fft_f = LinRange(0.0, 1/(2*pi/omega_z(trap, species)/SAVE_OVERSAMPLING)/2, length(fft_v))

    const SPAN = 40e3

    plot(fft_f/1e3, fft_v, labels="Simulated resonator voltage", plot_title="Dip of 187Re30+")
    xlims!((omega_res/2/pi-SPAN/2, omega_res/2/pi+SPAN/2)./1e3)
    ylims!((-80, -42))
    xlabel!("Frequency / kHz")

    savefig(joinpath(@__DIR__, "resonator_dip_mpi.png"))
end


MPI.Finalize()