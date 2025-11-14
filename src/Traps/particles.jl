struct Particles{R, V, M, Q, E, B}
    r :: R
    v :: V
    q :: Q
    m :: M
    E :: E
    B :: B
end

function Particles(r::AbstractMatrix, v::AbstractMatrix, q::AbstractVector, m::AbstractVector)
    return Particles(r, v, q, m, similar(r), similar(r))
end

# Just for convenience, there is also a keyword version:
Particles(;r::AbstractMatrix, v::AbstractMatrix, q::AbstractVector, m::AbstractVector) = Particles(r, v, q, m)

function N_particles(particles::Particles)
    return size(particles.r)[2]
end