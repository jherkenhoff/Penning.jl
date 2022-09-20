
using StaticArrays

"""
# Fields:
- `species`: Instance of type [Species](@ref), specifying the type (charge and mass) of particles in this collection
- `r`: Position of the particles in this collection
- `v`: Velocities of the particles in this collection
- `E`: Used to store the electric field at the positions of the individual particles during simulation
- `E`: Used to store the magnetic field at the positions of the individual particles during simulation
- `damping`: 3-dimensional vector specifying an artificial damping constant for all particles in this collection
"""
mutable struct ParticleCollection
    species :: Species
    r :: Vector{MVector{3,Float64}}
    v :: Vector{MVector{3,Float64}}
    E :: Vector{MVector{3,Float64}}
    B :: Vector{MVector{3,Float64}}
    damping :: SVector{3,Float64}
end

"""
    ParticleCollection(species, distribution)
Function for creating a [ParticleCollection](@ref) using a given [Species](@ref)
"""
function ParticleCollection(species::Species, r₀::AbstractVector{<:AbstractVector{<:Number}}, v₀::AbstractVector{<:AbstractVector{<:Number}}; damping=zeros(3))
    @assert length(r₀) == length(v₀)
    N = length(r₀)
    r = [MVector{3, Float64}(r₀[i]) for i in 1:N]
    v = [MVector{3, Float64}(v₀[i]) for i in 1:N]
    E = [MVector{3, Float64}(zeros(3)) for _ in 1:N]
    B = [MVector{3, Float64}(zeros(3)) for _ in 1:N]
    return ParticleCollection(species, r, v, E, B, SVector{3, Float64}(damping))
end

"""
    N_particles(collection)
Retrieve the number of particles of a [ParticleCollection](@ref).
"""
@inline function N_particles(collection::ParticleCollection)
    return length(collection.r)
end