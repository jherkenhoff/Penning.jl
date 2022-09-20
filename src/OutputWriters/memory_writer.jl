"""
    MemoryWriter <: AbstractOutputWriter
An output writer for writing to memory (ram).
"""
struct MemoryWriter{O, T} <: AbstractOutputWriter
    obs :: O
    t :: Vector{Float64}
    mem :: Vector{T}
    schedule :: AbstractSchedule
end

"""
    MemoryWriter(observable, schedule)
A `MemoryWriter` writes the value of an `observable`
into memory (ram) at time intervals specified by `schedule`.
Each time data is saved, the current simulation time is saved alongside with the data.
"""
function MemoryWriter(obs::AbstractScalarObservable, schedule::AbstractSchedule)
    t = Vector{Float64}()
    mem = Vector{Float64}()
    return MemoryWriter(obs, t, mem, schedule)
end

function MemoryWriter(obs::AbstractVectorObservable, schedule::AbstractSchedule)
    t = Vector{Float64}()
    mem = Vector{Vector{Float64}}()
    return MemoryWriter(obs, t, mem, schedule)
end

function (writer::MemoryWriter)(setup::Setup)
    t = setup.clock.time
    push!(writer.t, t)
    push!(writer.mem, deepcopy(writer.obs(setup)))
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