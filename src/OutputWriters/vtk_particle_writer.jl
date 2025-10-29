using WriteVTK

using Penning.Utils
using Penning.Constants
using Penning.Particles
using Penning.Setups
using Penning.Traps
using Penning.Observables
using Penning.Selections

import Penning.Common

struct VtkParticleWriter{SEL, O, P, SCH<:AbstractSchedule} <: AbstractOutputWriter
    selection::SEL
    observables :: O
    pvd :: P
    filepath :: String
    schedule::SCH
end

function VtkParticleWriter(filepath::String, selection::AbstractVector{<:AbstractParticleSelection}, schedule::AbstractSchedule; observables=(;))
    pvd = paraview_collection(filepath)
    return VtkParticleWriter(selection, observables, pvd, filepath, schedule)
end

function VtkParticleWriter(filepath::String, selection::AbstractParticleSelection, schedule::AbstractSchedule; observables=(;))
    return VtkParticleWriter(filepath, [selection], observables, filepath, schedule)
end

function write_output(writer::VtkParticleWriter, setup::Setup)
    filename = "$(writer.filepath)_$(setup.clock.iteration)"

    r = get_particle_selection_r.(writer.selection, (setup,))

    cells = [MeshCell(VTKCellTypes.VTK_VERTEX, (i, )) for i = 1:length(r)]

    vtk_grid(filename, reduce(hcat, r), cells, compress=false) do vtk
        for (key, observable) in pairs(writer.observables)
            obs = observe.((observable,), writer.selection, (setup,))
            vtk[String(key)] = reduce(hcat, obs)
        end
        #vtk["PE_TRAP"] = reduce(hcat, PE)/e
        #vtk["KE"] = reduce(hcat, KE)

        # Write to disk
        vtk_save(vtk)

        # Add to PVD collection
        writer.pvd[setup.clock.time] = vtk
    end
end

function Common.checkpoint!(writer::VtkParticleWriter)
    vtk_save(writer.pvd)
end

function Common.finalize!(writer::VtkParticleWriter)
    vtk_save(writer.pvd)
end