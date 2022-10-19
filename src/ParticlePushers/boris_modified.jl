using LinearAlgebra
using StaticArrays

struct ModifiedBorisPusher <: AbstractParticlePusher
end

function update_velocity!(pusher::ModifiedBorisPusher, v::AbstractVector{<:Number}, E::AbstractVector{<:Number}, B::AbstractVector{<:Number}, damping::AbstractVector{<:Number}, q::Number, m::Number, dt::Number)
    # TODO: tan() can be approximated to gain speed (?)
    norm_B = norm(B)
    if norm_B == 0.0 throw(DomainError("Zero B-field is not supported by ModifiedBorisPusher")) end
    f1 = tan(q*dt/m/2*norm_B)/norm_B
    f2 = 2*f1/(1+f1^2*dot(B, B))

    v1 = v + q / m * E * dt / 2
    v2 = v1 + f1 * cross(v1, B)
    v3 = v1 + f2 * cross(v2, B)

    v .= v3 + q / m * E * dt / 2

    # Add damping:
    v .+= -damping .* v / m * dt
end

function initial_particle_push!(pusher::ModifiedBorisPusher, r::AbstractVector{<:Number}, v::AbstractVector{<:Number}, E::AbstractVector{<:Number}, B::AbstractVector{<:Number}, damping::AbstractVector{<:Number}, q::Number, m::Number, dt::Number)
    # Step velocity one step back
    update_velocity!(pusher, v, E, B, damping, q, m, -dt/2)
    # Do not step position
    # After that, we can do our first "real" push
    push_particle!(pusher, r, v, E, B, damping, q, m, dt)
end

function push_particle!(pusher::ModifiedBorisPusher, r::AbstractVector{<:Number}, v::AbstractVector{<:Number}, E::AbstractVector{<:Number}, B::AbstractVector{<:Number}, damping::AbstractVector{<:Number}, q::Number, m::Number, dt::Number)
    update_velocity!(pusher, v, E, B, damping, q, m, dt)

    # Calc new position
    r .+= v * dt
end