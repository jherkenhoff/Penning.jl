
using Penning.Utils
using Penning.Utils.Bessel
using Penning.Constants

struct TECavityExcitation <: AbstractField
    m :: Int
    n :: Int
    p :: Int
    z_0 :: Float64
    rho_0 :: Float64
    E_0 :: Float64
    omega :: Float64
    besseljp_zero :: Float64
end

function TECavityExcitation(m::Integer, n::Integer, p::Integer, z_0::Number, rho_0::Number; E_0::Number=1)
    zero = besseljp_zero(m, n)
    omega = c * sqrt((zero / rho_0)^2 + (p * pi / 2 /z_0)^2)
    return TECavityExcitation(m, n, p, z_0, rho_0, E_0, omega, zero)
end

function calc_E_field(exc::TECavityExcitation, r::AbstractVector{<:Number}, t::Number)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    return SVector{3, Float64}( exc.E_0 * exc.omega/c * (exc.rho_0/exc.besseljp_zero)^2 * sin(exc.p*pi/2 * (z/exc.z_0 + 1)) * 
        (rho_hat * safe_divide(exc.m, rho) * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) - 
        phi_hat * exc.besseljp_zero / exc.rho_0 * besseljp(exc.m, exc.besseljp_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi)))
end

function set_E_field!(exc::TECavityExcitation, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)
    
    E .= exc.E_0 * exc.omega/c * (exc.rho_0/exc.besseljp_zero)^2 * sin(exc.p*pi/2 * (z/exc.z_0 + 1)) * 
        (rho_hat * safe_divide(exc.m, rho) * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) - 
        phi_hat * exc.besseljp_zero / exc.rho_0 * besseljp(exc.m, exc.besseljp_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi))
    nothing
end

function add_E_field!(exc::TECavityExcitation, E::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)
    
    E .+= exc.E_0 * exc.omega/c * (exc.rho_0/exc.besseljp_zero)^2 * sin(exc.p*pi/2 * (z/exc.z_0 + 1)) * 
        (rho_hat * safe_divide(exc.m, rho) * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) - 
        phi_hat * exc.besseljp_zero / exc.rho_0 * besseljp(exc.m, exc.besseljp_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi))
    nothing
end

function calc_B_field(exc::TECavityExcitation, r::AbstractVector{<:Number}, t::Number)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    return SVector{3, Float64}( exc.E_0/c * (z_hat * besselj(exc.m, exc.besseljp_zero*rho/exc.rho_0) * sin(exc.p * pi/2 * (z/exc.z_0 + 1)) * cos(exc.omega * t + exc.m*phi) + 
        exc.p*pi/2/exc.z_0 * (exc.rho_0/exc.besseljp_zero)^2 * cos(exc.p * pi/2 * (z/exc.z_0 + 1)) *
        (rho_hat * exc.besseljp_zero/exc.rho_0 * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) -
        phi_hat * safe_divide(exc.m, rho) * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi))))
end

function set_B_field!(exc::TECavityExcitation, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    B .= exc.E_0/c * (z_hat * besselj(exc.m, exc.besseljp_zero*rho/exc.rho_0) * sin(exc.p * pi/2 * (z/exc.z_0 + 1)) * cos(exc.omega * t + exc.m*phi) + 
        exc.p*pi/2/exc.z_0 * (exc.rho_0/exc.besseljp_zero)^2 * cos(exc.p * pi/2 * (z/exc.z_0 + 1)) *
        (rho_hat * exc.besseljp_zero/exc.rho_0 * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) -
        phi_hat * safe_divide(exc.m, rho) * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi)))
end

function add_B_field!(exc::TECavityExcitation, B::AbstractVector{<:Number}, r::AbstractVector{<:Number}, t::Float64)
    rho, phi, z = cartesian2cylindrical(r)
    rho_hat, phi_hat, z_hat = cylindrical_unit_vectors(phi)

    B .+= exc.E_0/c * (z_hat * besselj(exc.m, exc.besseljp_zero*rho/exc.rho_0) * sin(exc.p * pi/2 * (z/exc.z_0 + 1)) * cos(exc.omega * t + exc.m*phi) + 
        exc.p*pi/2/exc.z_0 * (exc.rho_0/exc.besseljp_zero)^2 * cos(exc.p * pi/2 * (z/exc.z_0 + 1)) *
        (rho_hat * exc.besseljp_zero/exc.rho_0 * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * cos(exc.omega * t + exc.m*phi) -
        phi_hat * safe_divide(exc.m, rho) * besselj(exc.m, exc.besseljp_zero * rho/exc.rho_0) * sin(exc.omega * t + exc.m*phi)))
end