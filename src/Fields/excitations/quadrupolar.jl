using StaticArrays

mutable struct QuadrupolarExcitationField <: AbstractField
    omega :: Float64
    A :: Float64
end

function calc_E_field(exc::QuadrupolarExcitationField, r::AbstractVector{<:Number}, t::Float64)
    return SVector{3, Float64}(exc.A*sin(exc.omega*t) .* [r[3], 0, r[1]])
end

function set_E_field!(exc::QuadrupolarExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    A = exc.A*sin(exc.omega*t)
    E[1] = A.*r[3]
    E[2] = 0.0
    E[3] = A.*r[1]
    nothing
end

function add_E_field!(exc::QuadrupolarExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    A = exc.A*sin(exc.omega*t)
    E[1] += A.*r[3]
    E[3] += A.*r[1]
    nothing
end

function calc_B_field!(exc::QuadrupolarExcitationField, r::AbstractVector{<:Number}, t::Float64)
    return @SVector zeros(3)
end

function set_B_field!(exc::QuadrupolarExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    B .= 0.0
    nothing
end

function add_B_field!(exc::QuadrupolarExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    nothing
end