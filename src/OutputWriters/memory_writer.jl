"""
    MemoryWriter <: AbstractOutputWriter
An output writer for writing to memory (RAM).
"""
struct MemoryWriter{O<:AbstractObservable, S<:AbstractSelection, T} <: AbstractOutputWriter
    observable :: O
    selection :: S
    t :: Vector{Float64}
    mem :: Vector{T}
    schedule :: AbstractSchedule
end

"""
    MemoryWriter(observable, selection, schedule)
A `MemoryWriter` writes the value of an `observable`
into memory (ram) at time intervals specified by `schedule`.
Each time data is saved, the current simulation time is saved alongside with the data.
"""
function MemoryWriter(observable::AbstractScalarObservable, selection::AbstractSingleParticleSelection, schedule::AbstractSchedule)
    t = Vector{Float64}()
    mem = Vector{Float64}()
    return MemoryWriter(observable, selection, t, mem, schedule)
end

function MemoryWriter(observable::AbstractScalarObservable, selection::AbstractMultiParticleSelection, schedule::AbstractSchedule)
    t = Vector{Float64}()
    mem = Vector{Vector{Float}}()
    return MemoryWriter(observable, selection, t, mem, schedule)
end

function MemoryWriter(observable::AbstractVectorObservable, selection::AbstractSingleParticleSelection, schedule::AbstractSchedule)
    t = Vector{Float64}()
    mem = Vector{Vector{Float64}}()
    return MemoryWriter(observable, selection, t, mem, schedule)
end

function MemoryWriter(observable::AbstractVectorObservable, selection::AbstractMultiParticleSelection, schedule::AbstractSchedule)
    t = Vector{Float64}()
    mem = Vector{Vector{Vector{Float64}}}()
    return MemoryWriter(observable, selection, t, mem, schedule)
end

function (writer::MemoryWriter)(setup::Setup)
    t = setup.clock.time
    push!(writer.t, t)
    r = observe(writer.observable, writer.selection, setup)
    push!(writer.mem, deepcopy(r))
    nothing
end

function reset!(writer::MemoryWriter)
    empty!(writer.t)
    empty!(writer.mem)
    nothing
end

Base.summary(writer::MemoryWriter) = 
    string("Memory writer on ", summary(writer.schedule))

function Base.show(io::IO, writer::MemoryWriter)
    return print(io, "Memory writer\n",
                     "├── Schedule: $(summary(writer.schedule))\n",
                     "└── Entry count: $(length(writer.mem))")
end