using WriteVTK

using Penning.Utils
using Penning.Constants
using Penning.Particles
using Penning.Setups
using Penning.Traps
using Penning.Fields

struct VtkFieldWriter{T, F, P} <: AbstractOutputWriter
    filepath :: String
    trap :: T
    field :: F
    points :: P
    schedule :: AbstractSchedule
    pvd
end

function VtkFieldWriter(filepath::String, trap, field, points::Array{Float64, 4}, schedule::AbstractSchedule)
    pvd = paraview_collection(filepath)
    return VtkFieldWriter(filepath, trap, field, points, schedule, pvd)
end


function (writer::VtkFieldWriter)(setup::Setup)
    filename = "$(writer.filepath)_$(setup.clock.iteration)"

    t = setup.clock.time

    vtk_grid(filename, writer.points, compress=false) do vtk

        vtk["E"] = mapslices(r -> calc_E_field(setup.traps[writer.trap].fields[writer.field], r, t), writer.points, dims=(1))
        vtk["B"] = mapslices(r -> calc_B_field(setup.traps[writer.trap].fields[writer.field], r, t), writer.points, dims=(1))

        # Write to disk
        vtk_save(vtk)

        # Add to PVD collection
        writer.pvd[t] = vtk
    end
end

function finalize!(writer::VtkFieldWriter)
    vtk_save(writer.pvd)
end