
"""
    DipolarExcitationField(ω, A)
Electric dipolar RF excitation field with angular frequency `ω` given in in rad/s. The amplitude 
and direction of the electric dipole field is specified by the three-dimensional vector argument `A`.

```math
\\vec{E} = \\vec{A} \\cdot \\sin (\\omega\\, t)
\\qquad
\\vec{B} = \\vec{0}
```
"""
mutable struct DipolarExcitationField <: AbstractField
    ω :: Float64
    A :: MVector{3, Float64}
end

function DipolarExcitationField(ω::Number, A::AbstractVector{<:Number})
    return DipolarExcitationField(ω, MVector{3, Float64}(A))
end

function calc_E_field(exc::DipolarExcitationField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}( exc.A .* sin(exc.ω*t) )
end

function set_E_field!(exc::DipolarExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E .= exc.A .* sin(exc.ω*t)
    nothing
end

function add_E_field!(exc::DipolarExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E .+= exc.A .* sin(exc.ω*t)
    nothing
end

function calc_B_field(exc::DipolarExcitationField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}( zeros(3) )
end

function set_B_field!(exc::DipolarExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    B .= 0.0
    nothing
end

function add_B_field!(exc::DipolarExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    nothing
end