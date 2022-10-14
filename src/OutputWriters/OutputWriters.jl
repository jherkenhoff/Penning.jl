module OutputWriters

import Penning.Common: finalize!, checkpoint!
using Penning.Utils
using Penning.Selections
using Penning.Observables
using Penning.Setups

import Penning: reset!

export
    VolumeExtractor
export
    AbstractOutputWriter,
    VtkParticleWriter,
    VtkFieldWriter,
    MemoryWriter, PositionMemoryWriter, CircuitMemoryWriter,
    finalize!,
    checkpoint!,
    init_output_writer!
 

abstract type AbstractOutputWriter end

checkpoint!(writer::AbstractOutputWriter) = nothing
finalize!(writer::AbstractOutputWriter) = nothing
reset!(writer::AbstractOutputWriter) = nothing
init_output_writer!(writer::AbstractOutputWriter, setup::Setup) = nothing

include("output_writer_utils.jl")
include("FieldExtractors/FieldExtractors.jl")
include("vtk_particle_writer.jl")
include("vtk_field_writer.jl")
include("memory_writer.jl")

using .FieldExtractors

end # module