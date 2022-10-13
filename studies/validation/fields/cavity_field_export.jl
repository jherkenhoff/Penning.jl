using Penning

const OVERSAMPLING = 100

trap = Trap(
    fields = (
        TMCavityExcitationField(1, 2, 2, 3e-3, 3e-3),
    )
)

setup = Setup(
    traps = (
        trap,
    )
)

sim = Simulation(
    setup, 
    dt=dt=2*pi/trap.fields[1].ω/OVERSAMPLING,
    output_writers=(
        VtkFieldWriter("studies/data/excitation_field", 1, 1, VolumeExtractor(6e-3, 6e-3, 6e-3, nx=60, ny=60, nz=60), IterationInterval(1)),
    )
)

run!(sim, run_until_iteration=OVERSAMPLING)

finalize!(sim)