
using Penning.Constants

"""
    PlaneWaveExcitationField(ω, E₀)
"""
mutable struct PlaneWaveExcitationField <: AbstractField
    ω :: Float64
    E₀ :: Float64
end

function calc_E_field(exc::PlaneWaveExcitationField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}( [
        exc.E₀ * sin(exc.ω * (t - r[3]/c)),
        0.0,
        0.0
    ])
end

function set_E_field!(exc::PlaneWaveExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    E[1] = exc.E₀ * sin(exc.ω * (t - r[3]/c))
    E[2] = 0.0
    E[3] = 0.0
    nothing
end

function add_E_field!(exc::PlaneWaveExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    E[1] += exc.E₀ * sin(exc.ω * (t - r[3]/c))
    nothing
end

function calc_B_field(exc::PlaneWaveExcitationField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}( [
        0.0,
        exc.E₀/c * sin(exc.ω * (t - r[3]/c)),
        0.0
    ])
end

function set_B_field!(exc::PlaneWaveExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    B[1] = 0.0
    B[2] = exc.E₀/c * sin(exc.ω * (t - r[3]/c))
    B[3] = 0.0
    nothing
end

function add_B_field!(exc::PlaneWaveExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    B[2] += exc.E₀/c * sin(exc.ω * (t - r[3]/c))
    nothing
end