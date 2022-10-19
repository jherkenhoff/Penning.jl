module OutputWriters

using Penning.Utils
using Penning.Selections
using Penning.Observables
using Penning.Setups

import Penning.Common

export
    AbstractOutputWriter,
    VtkParticleWriter,
    VtkFieldWriter,
    MemoryWriter,
    write_output,
    VolumeExtractor
 

abstract type AbstractOutputWriter end

Common.checkpoint!(writer::AbstractOutputWriter) = nothing
Common.finalize!(writer::AbstractOutputWriter) = nothing
Common.reset!(writer::AbstractOutputWriter) = nothing
Common.init!(writer::AbstractOutputWriter, setup::Setup) = nothing

include("output_writer_utils.jl")
include("FieldExtractors/FieldExtractors.jl")
include("vtk_particle_writer.jl")
include("vtk_field_writer.jl")
include("memory_writer.jl")

using .FieldExtractors

end # module