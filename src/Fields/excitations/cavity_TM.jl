
using Penning.Utils: cylindrical2cartesian, cartesian2cylindrical, cylindrical_unit_vectors
using Penning.Utils.Bessel
using Penning.Constants

struct TMCavityExcitationField <: AbstractField
    m :: Int
    n :: Int
    p :: Int
    z_0 :: Float64
    rho_0 :: Float64
    E_0 :: Float64
    omega :: Float64
    besselj_zero :: Float64
end

function TMCavityExcitation(m::Integer, n::Integer, p::Integer, z_0::Number, rho_0::Number; E_0::Number=1)
    zero = besselj_zero(m, n)
    omega = c * sqrt((zero / rho_0)^2 + (p * pi / 2 /z_0)^2)
    return TMCavityExcitation(m, n, p, z_0, rho_0, E_0, omega, zero)
end

function calc_E_field(exc::TMCavityExcitationField, r::AbstractVector{<:Number}, t::Number)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    return SVector{3, Float64}( exc.E_0 * (z_hat * besselj(exc.m, exc.besselj_zero*rho/exc.rho_0) * cos(exc.p * pi/2 * (z/exc.z_0 + 1)) * cos(exc.omega * t + exc.m*phi) -
        exc.p*pi/2/exc.z_0 * (exc.rho_0/exc.besselj_zero)^2 * sin(exc.p * pi/2 * (z/exc.z_0 + 1)) *
        (rho_hat * exc.besselj_zero/exc.rho_0 * besseljp(exc.m, exc.besselj_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) -
        phi_hat * exc.m/rho * besselj(exc.m, exc.besselj_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi))))
end

function set_E_field!(exc::TMCavityExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)
    
    E .= exc.E_0 * (z_hat * besselj(exc.m, exc.besselj_zero*rho/exc.rho_0) * cos(exc.p * pi/2 * (z/exc.z_0 + 1)) * cos(exc.omega * t + exc.m*phi) -
        exc.p*pi/2/exc.z_0 * (exc.rho_0/exc.besselj_zero)^2 * sin(exc.p * pi/2 * (z/exc.z_0 + 1)) *
        (rho_hat * exc.besselj_zero/exc.rho_0 * besseljp(exc.m, exc.besselj_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) -
        phi_hat * exc.m/rho * besselj(exc.m, exc.besselj_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi)))
    nothing
end

function add_E_field!(exc::TMCavityExcitationField, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)
    
    E .+= exc.E_0 * (z_hat * besselj(exc.m, exc.besselj_zero*rho/exc.rho_0) * cos(exc.p * pi/2 * (z/exc.z_0 + 1)) * cos(exc.omega * t + exc.m*phi) -
        exc.p*pi/2/exc.z_0 * (exc.rho_0/exc.besselj_zero)^2 * sin(exc.p * pi/2 * (z/exc.z_0 + 1)) *
        (rho_hat * exc.besselj_zero/exc.rho_0 * besseljp(exc.m, exc.besselj_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) -
        phi_hat * exc.m/rho * besselj(exc.m, exc.besselj_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi)))
    nothing
end

function calc_B_field(exc::TMCavityExcitationField, r::AbstractVector{<:Number}, t::Number)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    return SVector{3, Float64}( exc.E_0/c * exc.omega/c * (exc.rho_0/exc.besselj_zero)^2 * cos(exc.p*pi/2 * (z/exc.z_0 + 1)) * 
        (-rho_hat * exc.m./rho * besselj(exc.m, exc.besselj_zero * rho/exc.rho_0) * cos(exc.omega * t .+ exc.m*phi) +
        phi_hat * exc.besselj_zero / exc.rho_0 * besseljp(exc.m, exc.besselj_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi)))
end

function set_B_field!(exc::TMCavityExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    B .= exc.E_0/c * exc.omega/c * (exc.rho_0/exc.besselj_zero)^2 * cos(exc.p*pi/2 * (z/exc.z_0 + 1)) * 
        (-rho_hat * exc.m./rho * besselj(exc.m, exc.besselj_zero * rho/exc.rho_0) * cos(exc.omega * t .+ exc.m*phi) +
        phi_hat * exc.besselj_zero / exc.rho_0 * besseljp(exc.m, exc.besselj_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi))
end

function add_B_field!(exc::TMCavityExcitationField, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    B .+= exc.E_0/c * exc.omega/c * (exc.rho_0/exc.besselj_zero)^2 * cos(exc.p*pi/2 * (z/exc.z_0 + 1)) * 
        (-rho_hat * exc.m./rho * besselj(exc.m, exc.besselj_zero * rho/exc.rho_0) * cos(exc.omega * t .+ exc.m*phi) +
        phi_hat * exc.besselj_zero / exc.rho_0 * besseljp(exc.m, exc.besselj_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi))
end