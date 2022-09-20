
calc_omega_z(U₀, c₂, B₀, q, m) = sqrt(2*q*c₂ * U₀ / m)
calc_omega_c(U₀, c₂, B₀, q, m) = abs(q)/m*B₀
calc_omega_p(U₀, c₂, B₀, q, m) = 1/2 * (calc_omega_c(U₀, c₂, B₀, q, m) + sqrt(calc_omega_c(U₀, c₂, B₀, q, m)^2 - 2*calc_omega_z(U₀, c₂, B₀, q, m)^2))
calc_omega_m(U₀, c₂, B₀, q, m) = 1/2 * (calc_omega_c(U₀, c₂, B₀, q, m) - sqrt(calc_omega_c(U₀, c₂, B₀, q, m)^2 - 2*calc_omega_z(U₀, c₂, B₀, q, m)^2))

function calc_eigenfrequencies(U₀, c₂, B₀, q, m)
    return calc_omega_c(U₀, c₂, B₀, q, m),
        calc_omega_p(U₀, c₂, B₀, q, m),
        calc_omega_m(U₀, c₂, B₀, q, m),
        calc_omega_z(U₀, c₂, B₀, q, m)
end