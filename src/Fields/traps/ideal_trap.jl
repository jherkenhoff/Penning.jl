using Penning.Particles

using LinearAlgebra: norm
using StaticArrays

"""
    IdealTrapField(U₀, c₂, B₀)
Field of an ideal Penning trap, specified by potential depth `U₀` in volts, quadratic field coefficient `c₂` in 1/m² and magnetic field strength `B₀` in Tesla.
The magnetic field component is aligned in the ``z`` direction.

```math
\\vec{E} = c_2\\, U_0 
\\left( \\begin{array}{c}
x \\\\
y \\\\
-2z
\\end{array} \\right)
\\qquad
\\vec{B} =
\\left( \\begin{array}{c}
0 \\\\
0 \\\\
B_0
\\end{array} \\right)
```
"""
mutable struct IdealTrapField <: AbstractField
    U₀ :: Float64
    c₂ :: Float64
    B₀ :: Float64
end

function calc_E_field(field::IdealTrapField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}([
        field.U₀ * field.c₂ * r[1],
        field.U₀ * field.c₂ * r[2],
        -2 * field.U₀ * field.c₂ * r[3]
    ])
end

function set_E_field!(field::IdealTrapField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E[1] = field.U₀ * field.c₂ * r[1]
    E[2] = field.U₀ * field.c₂ * r[2]
    E[3] = -2 * field.U₀ * field.c₂ * r[3]
    nothing
end

function add_E_field!(field::IdealTrapField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E[1] += field.U₀ * field.c₂ * r[1]
    E[2] += field.U₀ * field.c₂ * r[2]
    E[3] += -2 * field.U₀ * field.c₂ * r[3]
    nothing
end

function calc_B_field(field::IdealTrapField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}([0, 0, field.B₀])
end

function set_B_field!(field::IdealTrapField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    B[1] = 0.0
    B[2] = 0.0
    B[3] = field.B₀
    nothing
end

function add_B_field!(field::IdealTrapField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    B[3] += field.B₀
    nothing
end

function calc_field_PE(field::IdealTrapField, r::AbstractVector{<:Number}, t::Number, q::Float64)
    return norm(q*field.U₀*field.c₂ * r.^2 .* [-1/2; -1/2; 1])
end