using Plots
using FFTW
using Base.Threads
using Penning

const N_AXIAL_CYCLES = 10000
const OVERSAMPLING = 20
const SAVE_OVERSAMPLING = 4
const N_AVERAGES = 16

t = []
fft_v_all = Vector{Vector{Float64}}(undef, N_AVERAGES)
@info "Running $N_AVERAGES averages on max. $(Threads.nthreads()) threads"
Threads.@threads for i = 1:N_AVERAGES
    species = Ion(187, 30)
    particle_distribution = SingleParticleDistribution([0, 0, 1e-6], [0, 0, 0,])
    particles = ParticleCollection(species, particle_distribution)

    trap = IdealTrap(-50.0, -14960.0, 7.0)
    trap.particles[:particles] = particles
    trap.electrodes[:axial] = AxialParallelPlateElectrode(0.2e-3)

    circuit = SSCircuitResistor(10e6, [(:trap, :axial)], T=4.2)

    setup = Setup(circuit)
    setup.traps[:trap] = trap

    sim = Simulation(setup, dt=2*pi/calc_omega_z(trap, species)/OVERSAMPLING, stop_iteration=N_AXIAL_CYCLES*OVERSAMPLING)
    save_schedule = IterationInterval(OVERSAMPLING/SAVE_OVERSAMPLING)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particles, 1, 3), save_schedule)
    sim.output_writers[:v] = MemoryWriter(ElectrodeVoltageObservable(:trap, :axial), save_schedule)

    run!(sim)

    t_local = sim.output_writers[:z].t
    z = sim.output_writers[:z].mem
    v = sim.output_writers[:v].mem

    if i == 1
        push!(t, t_local)
    end


    fft_v_all[i] = 20*log10.(abs.(rfft(v)))
end

t = t[1]

fft_v_avg = dropdims(sum(permutedims(hcat(fft_v_all...)), dims=(1)), dims=(1)) / N_AVERAGES
fft_f = LinRange(0.0, 1/(t[2]-t[1])/2, length(fft_v_avg))

plot(fft_f/1e3, fft_v_avg)
const SPAN = 100e3
center = 740e3
xlims!((center-SPAN/2, center+SPAN/2)./1e3)