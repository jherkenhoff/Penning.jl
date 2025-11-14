using Random

function boltzman_velocities(N::Int, T::Number)
    return hcat([randn(3)*T for i in 1:N]...)
end

function zero_velocities(N::Int)
    return hcat([0 for i in 1:N]...)
end

function rotating_spheroid_velocities(r::AbstractMatrix{<:Number}, ωᵣ::AbstractVector{<:Number}, r₀::AbstractVector{<:Number})
    return hcat([cross(ωᵣ, rᵢ - r₀) for rᵢ in eachcol(r)]...)
end