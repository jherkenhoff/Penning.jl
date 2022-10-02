
using Penning.Utils: cylindrical2cartesian, cartesian2cylindrical, cylindrical_unit_vectors
using Penning.Utils.Bessel
using Penning.Constants

mutable struct TMCavityExcitationField <: AbstractField
    m :: Int
    n :: Int
    p :: Int
    z₀ :: Float64
    ρ₀ :: Float64
    E₀ :: Float64
    ω :: Float64
    besselj_zero :: Float64
end

"""
    TMCavityExcitationField(m, n, p, z₀, ρ₀; E₀)
"""
function TMCavityExcitationField(m::Integer, n::Integer, p::Integer, z₀::Number, ρ₀::Number; E₀::Number=1)
    zero = besselj_zero(m, n)
    ω = c * sqrt((zero / ρ₀)^2 + (p * pi / 2 /z₀)^2)
    return TMCavityExcitationField(m, n, p, z₀, ρ₀, E₀, ω, zero)
end

function calc_E_field(exc::TMCavityExcitationField, r::AbstractVector{<:Number}, t::Number)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    return SVector{3, Float64}( exc.E₀ * (z_hat * besselj(exc.m, exc.besselj_zero*rho/exc.ρ₀) * cos(exc.p * pi/2 * (z/exc.z₀ + 1)) * cos(exc.ω * t + exc.m*phi) -
        exc.p*pi/2/exc.z₀ * (exc.ρ₀/exc.besselj_zero)^2 * sin(exc.p * pi/2 * (z/exc.z₀ + 1)) *
        (rho_hat * exc.besselj_zero/exc.ρ₀ * besseljp(exc.m, exc.besselj_zero * rho/exc.ρ₀) * cos(exc.ω * t + exc.m*phi) -
        phi_hat * exc.m/rho * besselj(exc.m, exc.besselj_zero * rho/exc.ρ₀) * sin(exc.ω * t + exc.m*phi))))
end

function set_E_field!(exc::TMCavityExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)
    
    E .= exc.E₀ * (z_hat * besselj(exc.m, exc.besselj_zero*rho/exc.ρ₀) * cos(exc.p * pi/2 * (z/exc.z₀ + 1)) * cos(exc.ω * t + exc.m*phi) -
        exc.p*pi/2/exc.z₀ * (exc.ρ₀/exc.besselj_zero)^2 * sin(exc.p * pi/2 * (z/exc.z₀ + 1)) *
        (rho_hat * exc.besselj_zero/exc.ρ₀ * besseljp(exc.m, exc.besselj_zero * rho/exc.ρ₀) * cos(exc.ω * t + exc.m*phi) -
        phi_hat * exc.m/rho * besselj(exc.m, exc.besselj_zero * rho/exc.ρ₀) * sin(exc.ω * t + exc.m*phi)))
    nothing
end

function add_E_field!(exc::TMCavityExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)
    
    E .+= exc.E₀ * (z_hat * besselj(exc.m, exc.besselj_zero*rho/exc.ρ₀) * cos(exc.p * pi/2 * (z/exc.z₀ + 1)) * cos(exc.ω * t + exc.m*phi) -
        exc.p*pi/2/exc.z₀ * (exc.ρ₀/exc.besselj_zero)^2 * sin(exc.p * pi/2 * (z/exc.z₀ + 1)) *
        (rho_hat * exc.besselj_zero/exc.ρ₀ * besseljp(exc.m, exc.besselj_zero * rho/exc.ρ₀) * cos(exc.ω * t + exc.m*phi) -
        phi_hat * exc.m/rho * besselj(exc.m, exc.besselj_zero * rho/exc.ρ₀) * sin(exc.ω * t + exc.m*phi)))
    nothing
end

function calc_B_field(exc::TMCavityExcitationField, r::AbstractVector{<:Number}, t::Number)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    return SVector{3, Float64}( exc.E₀/c * exc.ω/c * (exc.ρ₀/exc.besselj_zero)^2 * cos(exc.p*pi/2 * (z/exc.z₀ + 1)) * 
        (-rho_hat * exc.m./rho * besselj(exc.m, exc.besselj_zero * rho/exc.ρ₀) * cos(exc.ω * t .+ exc.m*phi) +
        phi_hat * exc.besselj_zero / exc.ρ₀ * besseljp(exc.m, exc.besselj_zero * rho/exc.ρ₀) * sin(exc.ω * t + exc.m*phi)))
end

function set_B_field!(exc::TMCavityExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    B .= exc.E₀/c * exc.ω/c * (exc.ρ₀/exc.besselj_zero)^2 * cos(exc.p*pi/2 * (z/exc.z₀ + 1)) * 
        (-rho_hat * exc.m./rho * besselj(exc.m, exc.besselj_zero * rho/exc.ρ₀) * cos(exc.ω * t .+ exc.m*phi) +
        phi_hat * exc.besselj_zero / exc.ρ₀ * besseljp(exc.m, exc.besselj_zero * rho/exc.ρ₀) * sin(exc.ω * t + exc.m*phi))
end

function add_B_field!(exc::TMCavityExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    B .+= exc.E₀/c * exc.ω/c * (exc.ρ₀/exc.besselj_zero)^2 * cos(exc.p*pi/2 * (z/exc.z₀ + 1)) * 
        (-rho_hat * exc.m./rho * besselj(exc.m, exc.besselj_zero * rho/exc.ρ₀) * cos(exc.ω * t .+ exc.m*phi) +
        phi_hat * exc.besselj_zero / exc.ρ₀ * besseljp(exc.m, exc.besselj_zero * rho/exc.ρ₀) * sin(exc.ω * t + exc.m*phi))
end