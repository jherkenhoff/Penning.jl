using Random

function boltzman_velocities(N::Int, T::Number)
    return [randn(3)*T for i in 1:N]
end

function zero_velocities(N::Int)
    return [0 for i in 1:N]
end

function rotating_spheroid_velocities(
    r::AbstractVector{<:AbstractVector{<:Number}},
    ωᵣ::AbstractVector{<:Number},
    r₀::AbstractVector{<:Number}
)
    return [cross(ωᵣ, rᵢ - r₀) for rᵢ in r]
end