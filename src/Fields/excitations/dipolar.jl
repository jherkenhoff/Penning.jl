mutable struct DipolarExcitationField <: AbstractField
    omega :: Float64
    A :: MVector{3, Float64}
end

function DipolarExcitationField(omega::Number, A::AbstractVector{<:Number})
    return DipolarExcitationField(omega, MVector{3, Float64}(A))
end

function calc_E_field(exc::DipolarExcitationField, r::AbstractVector{<:Number}, t::Number)
    return SVector{3, Float64}( exc.A .* sin(exc.omega*t) )
end

function set_E_field!(exc::DipolarExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E .= exc.A .* sin(exc.omega*t)
    nothing
end

function add_E_field!(exc::DipolarExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Number)
    E .+= exc.A .* sin(exc.omega*t)
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