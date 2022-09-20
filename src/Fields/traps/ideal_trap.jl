using Penning.Particles

using LinearAlgebra: norm
using StaticArrays

struct IdealTrapField <: AbstractField
    U₀ :: Float64
    c₂ :: Float64
    B₀ :: Float64
end

function calc_E_field(trap::IdealTrapField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}([
        trap.U₀ * trap.c₂ * r[1],
        trap.U₀ * trap.c₂ * r[2],
        -2 * trap.U₀ * trap.c₂ * r[3]
    ])
end

function set_E_field!(trap::IdealTrapField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E[1] = trap.U₀ * trap.c₂ * r[1]
    E[2] = trap.U₀ * trap.c₂ * r[2]
    E[3] = -2 * trap.U₀ * trap.c₂ * r[3]
    nothing
end

function add_E_field!(trap::IdealTrapField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E[1] += trap.U₀ * trap.c₂ * r[1]
    E[2] += trap.U₀ * trap.c₂ * r[2]
    E[3] += -2 * trap.U₀ * trap.c₂ * r[3]
    nothing
end

function calc_B_field(trap::IdealTrapField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}([0, 0, trap.B₀])
end

function set_B_field!(trap::IdealTrapField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    B[1] = 0.0
    B[2] = 0.0
    B[3] = trap.B₀
    nothing
end

function add_B_field!(trap::IdealTrapField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    B[3] += trap.B₀
    nothing
end

function calc_field_PE(trap::IdealTrapField, r::AbstractVector{<:Number}, t::Number, q::Float64)
    return norm(q*trap.U₀*trap.c₂ * r.^2 .* [-1/2; -1/2; 1])
end