using Base.Threads
using Plots
using FFTW

using Penning

const OVERSAMPLING = 20
const SAVE_OVERSAMPLING = 10

# Trap parameters
const U₀ = -50.0
const c₂ = -15000.0
const B₀ = 1.0

# Detection system parameters
const R = 100e6
const D_eff = 5e-3
const T = 4.2

# PnP parameters
const A_exc = 0.025
const A_couple = 400.0
const T_cool = 10e-3
const T_exc = 3e-3
const T_evol = 1e-3
const T_couple = 10e-3
const T_readout = 5e-3

ion = Ion(187, 30)

omega_p, omega_m, omega_z = find_eigenfreqs(U₀, c₂, B₀, ion, OVERSAMPLING)

Threads.@threads for i = 1:1
    trap = Trap(
        fields = (
            trap     = IdealTrapField(U₀, c₂, B₀),
            dip_exc  = DipolarExcitationField(omega_p, [0.0, 0.0, 0.0]),
            quad_exc = QuadrupolarExcitationField(omega_p - omega_z, 0.0)
        ),
        particles = (
            ParticleCollection(ion, [[0, 0, 0]], [[0, 0, 0]]), 
        ),
        electrodes = (
            AxialParallelPlateElectrode(D_eff),
        )
    )

    setup = Setup(
        traps = (trap,),
        circuits = (CircuitResistor(R, T=T),),
        connections = (Connection(trap=1, electrode=1, circuit=1, pin=1),)
    )

    dt = 2*pi/omega_p/OVERSAMPLING
    sim = Simulation(
        setup,
        dt=dt,
        output_writers=Dict()
    )

    # Cooling
    sim.setup.traps[1].fields[:quad_exc].A = A_couple
    run!(sim, run_for_time=T_cool)
    sim.setup.traps[1].fields[:quad_exc].A = 0.0

    # Excitation
    sim.setup.traps[1].fields[:dip_exc].A[1] = A_exc
    run!(sim, run_for_time=T_exc)
    sim.setup.traps[1].fields[:dip_exc].A[1] = 0.0

    # Phase evolution
    run!(sim, run_for_time=T_evol)

    # Couple pulse
    sim.setup.traps[1].fields[:quad_exc].A = A_couple
    run!(sim, run_for_time=T_couple)
    sim.setup.traps[1].fields[:quad_exc].A = 0.0

    # Phase readout
    sim.output_writers[:z] = MemoryWriter(PositionComponentObservable(1, 1, 1, 3), AlignedTimeInterval(2*pi/omega_z/SAVE_OVERSAMPLING, dt))
    run!(sim, run_for_time=T_readout)

    # x = sim.output_writers[:x].mem
    # t_x = sim.output_writers[:x].t
    # plot(t_x*1e3, x*1e6)
    # ylabel!("\$x\$ amplitude / µm")
    # xlabel!("\$t\$ / ms")

    z = sim.output_writers[:z].mem
    t_z = sim.output_writers[:z].t
    plot(t_z*1e3, z*1e6)
    ylabel!("\$z\$ amplitude / µm")
    xlabel!("\$t\$ / ms")

    harminv_result = harminv_primary(t_z, z, omega_z/2/pi-1e3, omega_z/2/pi+1e3)

    println("Harminv phase: $(rad2deg(harminv_result.phase))")
end
