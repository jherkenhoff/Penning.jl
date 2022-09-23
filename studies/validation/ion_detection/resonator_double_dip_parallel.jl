
using ModelingToolkit, DifferentialEquations
using Base.Threads
using Plots
using FFTW
using DelimitedFiles
using UUIDs
using Penning

const N_AXIAL_CYCLES = 5000
const OVERSAMPLING = 20
const SAVE_OVERSAMPLING = 4
const Z_INIT_MAX = 1e-6
const N_AVERAGES = 2

const D_eff = 0.4e-3

const A_rf = 20000

const R = 10e6
const L = 4.3506e-3
const C = 10e-12
const omega_res = 1/sqrt(C*L)

const base_species = Ion(187, 30)
const base_trap = IdealTrap(-49.63, -14960.0, 0.5)

omega_c, omega_p, omega_m, omega_z = calc_eigenfrequencies(base_trap, base_species)

dt = 2*pi/omega_c/OVERSAMPLING

################################################################################
# Step 1: Let particle evolve freely to extract eigenfrequencies
################################################################################
function run_extract_eigenfrequencies(omega_c, omega_p, omega_m, omega_z, dt)
    particle_distribution = SingleParticleDistribution([1e-6, 0, 1e-6], [10, 0, 0])
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particle] = particles
    setup = Setup()
    setup.traps[:trap] = trap
    sim = Simulation(setup, dt=dt, stop_time=1000*2*pi/omega_z)

    save_x_schedule = AlignedTimeInterval(2*pi/omega_c/SAVE_OVERSAMPLING, dt)
    save_z_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt)
    sim.output_writers[:x] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 1), save_x_schedule)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 3), save_z_schedule)

    run!(sim)

    x_harminv_results = harminv(sim.output_writers[:x].t, sim.output_writers[:x].mem, omega_m/2/pi/2, omega_p/2/pi*2)
    z_harminv_results = harminv(sim.output_writers[:z].t, sim.output_writers[:z].mem, omega_z/2/pi/2, omega_z/2/pi*2)

    # Update theoretically calculated eigenfrequencies with newly found ones
    omega_m = x_harminv_results[1].f*2*pi
    omega_p = x_harminv_results[2].f*2*pi
    omega_z = z_harminv_results[1].f*2*pi

    dt = 2*pi/omega_c/OVERSAMPLING
    return omega_p, omega_m, omega_z, dt
end

omega_p, omeg_m, omega_z, dt = run_extract_eigenfrequencies(omega_c, omega_p, omega_m, omega_z, dt)

################################################################################
# Step 2: Validate sideband frequency
################################################################################
function run_validate_sideband(omega_p, omega_m, omega_z, dt)
    # Theoretical Rabi frequency: (http://hdl.handle.net/21.11116/0000-0005-6361-E)(Page 25, equation 2.46)
    Omega_R = A_rf/4*abs(base_species.q) / base_species.m /sqrt(omega_z*(omega_p-omega_m))
    T_exchange = 2*pi/Omega_R/4

    particle_distribution = SingleParticleDistribution([0, 0, 1e-6], [0, 0, 0])
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particle] = particles
    trap.excitations[:quadrupolar] = QuadrupolarExcitation(omega_p - omega_z, A_rf)
    setup = Setup()
    setup.traps[:trap] = trap
    sim = Simulation(setup, dt=dt, stop_time=T_exchange*1.5)

    save_z_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING/4, dt)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 3), save_z_schedule)

    run!(sim)

    t = sim.output_writers[:z].t
    z = sim.output_writers[:z].mem

    println("Theoretical double dip splitting: $(Omega_R/2/pi) Hz")

    plot(t*1e6, z)
    vline!([T_exchange*1e6], labels="Theoretical pi pulse duration")
    xlabel!("Time / µs")
end

run_validate_sideband(omega_p, omega_m, omega_z, dt)

################################################################################
# Step 3: Let simulation run for a bit, in order to thermalize all motions
################################################################################
function run_thermalize(omega_p, omega_z, dt)
    particle_distribution = SingleParticleDistribution()
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particle] = particles
    trap.electrodes[:axial] = AxialParallelPlateElectrode(D_eff)
    trap.excitations[:quadrupolar] = QuadrupolarExcitation(omega_p - omega_z, A_rf)

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

    sim = Simulation(setup, dt=dt, stop_time=1000*2*pi/omega_z)

    save_x_schedule = AlignedTimeInterval(2*pi/omega_c/SAVE_OVERSAMPLING, dt)
    save_z_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt)
    save_energy_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt)
    sim.output_writers[:x] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 1), save_x_schedule)
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(:trap, :particle, 1, 3), save_z_schedule)
    sim.output_writers[:energy] = MemoryWriter(SingleParticleTotalEnergy(:trap, :particle, 1), save_energy_schedule)

    run!(sim)

    t_z = sim.output_writers[:z].t
    z = sim.output_writers[:z].mem
    t_x = sim.output_writers[:x].t
    x = sim.output_writers[:x].mem
    t_energy = sim.output_writers[:energy].t
    energy = sim.output_writers[:energy].mem

    energy[1] = energy[2] # HACK: energy[1] is zero, and can therefore not be plotted in log plot. Therefore, we simply overwrite it with energy[2]

    plot(t_energy*1e3, energy, yaxis=:log)
    plot(t_energy*1e3, energy)

    r₀ = sim.setup.traps[:trap].particles[:particle].r[1]
    v₀ = sim.setup.traps[:trap].particles[:particle].v[1]

    return r₀, v₀ 
end

r₀, v₀ = run_thermalize(omega_p, omega_z, dt)

################################################################################
# Step 4:
################################################################################

function single_averag(r₀, v₀, dt, omega_z, omega_p)
    particle_distribution = SingleParticleDistribution(r₀, v₀)
    particles = ParticleCollection(deepcopy(base_species), particle_distribution)

    trap = deepcopy(base_trap)
    trap.particles[:particles] = particles
    trap.electrodes[:axial] = AxialParallelPlateElectrode(D_eff)
    trap.excitations[:quadrupolar] = QuadrupolarExcitation(omega_p - omega_z, A_rf)

    resistor = NoisyResistor(R=R, T=4.2, name=Symbol(UUIDs.uuid1()))
    inductor = Inductor(L=L, name=Symbol(UUIDs.uuid1()))
    capacitor = Capacitor(C=C, name=Symbol(UUIDs.uuid1()))
    ground = Ground(name=Symbol(UUIDs.uuid1()))

    connections = [
        connect(trap.electrodes[:axial].pin, resistor.p, inductor.p, capacitor.p)
        connect(resistor.n, inductor.n, capacitor.n, ground.g)
    ]
    circuit = Circuit(connections, [trap.electrodes[:axial].pin, resistor, inductor, capacitor, ground])

    setup = Setup(circuit)
    setup.traps[:trap] = trap

    sim = Simulation(setup, dt=dt, stop_time=N_AXIAL_CYCLES*2*pi/omega_z)

    save_schedule = AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt)
    sim.output_writers[:resistor_v] = MemoryWriter(CircuitObservable(resistor.v), save_schedule)

    run!(sim)
    
    t = sim.output_writers[:resistor_v].t
    v = Vector{Float64}(sim.output_writers[:resistor_v].mem)
    return t, rfft(v)
end

function run_averages(dt, omega_z, omega_p)
    t = []
    fft_v_all = Vector{Vector{Complex}}(undef, N_AVERAGES)
    @info "Running $N_AVERAGES averages on max. $(Threads.nthreads()) threads"
    Threads.@threads for i = 1:N_AVERAGES
        
        t_local, fft_v = single_averag(r₀, v₀, dt, omega_z, omega_p)

        if i == 1
            push!(t, t_local)
        end
        

        fft_v_all[i] = fft_v

        @info "Thread $i done"
    end

    #writedlm( "resonator_double_dip_mpi.csv",  fft_v, ',')
    
    fft_v_avg = dropdims(sum(permutedims(hcat(fft_v_all...)), dims=(1)), dims=(1)) / N_AVERAGES
    
    SPAN = 40e3
    
    t = t[1]
    
    fft_f = LinRange(0.0, 1/(t[2]-t[1])/2, length(fft_v_avg))
    plot(fft_f/1e3, 20*log10.(abs.(fft_v_avg)))
    #vline!([calc_omega_z(trap, species)/2/pi/1e3], labels="Theoretical axial freq")
    xlims!((omega_res/2/pi-SPAN/2, omega_res/2/pi+SPAN/2)./1e3)
    ylims!((-100, -30))
end

run_averages(dt, omega_z, omega_p)
