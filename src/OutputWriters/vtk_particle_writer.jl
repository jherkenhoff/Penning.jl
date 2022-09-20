using WriteVTK

using Penning.Utils
using Penning.Constants
using Penning.Particles
using Penning.Setups
using Penning.Traps

struct VtkParticleWriter{P, T, PA} <: AbstractOutputWriter
    schedule::AbstractSchedule
    trap :: T
    particles :: PA
    pvd :: P
    filepath :: String
end

function VtkParticleWriter(filepath::String, trap, particles, schedule::AbstractSchedule)

    pvd = paraview_collection(filepath)

    return VtkParticleWriter(schedule, trap, particles, pvd, filepath)
end

function (writer::VtkParticleWriter)(setup::Setup)
    filename = "$(writer.filepath)_$(setup.clock.iteration)"

    trap = setup.traps[writer.trap]
    r = trap.particles[writer.particles].r
    v = trap.particles[writer.particles].v
    q = trap.particles[writer.particles].species.q
    m = trap.particles[writer.particles].species.m

    #PE = calc_PE.((trap,), r, (q,))

    KE = [1/2 * m * v_single.^2 for v_single in v]

    N = N_particles(setup.traps[writer.trap].particles[writer.particles])
    cells = [MeshCell(VTKCellTypes.VTK_VERTEX, (i, )) for i = 1:N]

    vtk_grid(filename, reduce(hcat, r), cells, compress=false) do vtk
        #vtk["PE_TRAP"] = reduce(hcat, PE)/e
        vtk["KE"] = reduce(hcat, KE)

        # Write to disk
        vtk_save(vtk)

        # Add to PVD collection
        writer.pvd[setup.clock.time] = vtk
    end
end

function finalize_output_writer!(writer::VtkParticleWriter)
    vtk_save(writer.pvd)
end