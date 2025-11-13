using LinearAlgebra

# Particle stepping using boris method (https://www.particleincell.com/2011/vxb-rotation/)

struct BorisPusher <: AbstractParticlePusher
end

function initial_particle_push!(
    pusher::BorisPusher,
    v::AbstractVector{<:Number},
    E::AbstractVector{<:Number},
    B::AbstractVector{<:Number},
    q::Number,
    m::Number,
    dt::Number
)
    # Step velocity one step back
    tmp = q / m * B * 0.5 * -dt/2
    s = 2 * tmp / (1 + sum(tmp.^2))
    v_minus = v + q / m * E * 0.5 * -dt/2
    v_prime = v_minus + cross(v_minus, tmp)
    v_plus = v_minus + cross(v_prime, s)
    v .= v_plus + q / m * E * 0.5 * -dt/2

    # Do not step position

    # After that, we can do our first "real" push
    push_particle!(pusher, r, v, E, B, damping, q, m, dt)
end

function push_particle!(
    pusher::BorisPusher,
    v::AbstractVector{<:Number},
    E::AbstractVector{<:Number},
    B::AbstractVector{<:Number},
    q::Number,
    m::Number,
    dt::Number
)
    # Calc velocity
    tmp = q / m * B * 0.5 * dt
    s = 2 * tmp / (1 + sum(tmp.^2))
    v_minus = v + q / m * E * 0.5 * dt
    v_prime = v_minus + cross(v_minus, tmp)
    v_plus = v_minus + cross(v_prime, s)
    v .= v_plus + q / m * E * 0.5 * dt

    # Add damping:
    v .+= -damping .* v / m * dt

    # Calc new position
    r .+= v * dt
end