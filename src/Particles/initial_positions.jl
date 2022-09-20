using Random
using LinearAlgebra

"""
    spherical_homogeneous_positions(N, rho_max, z_max, r₀)
Create a particle distribution with `N` randomly, homogeneously distributed particles in a **spheroid** shape (with symmetry around the z axis).
The boundary of the distribution domain is specified by `rho_max` and `z_max`. The distribution can be spatially offset using the parameter `r₀`.
"""
function spherical_homogeneous_positions(N::Int, rho_max::Number, z_max::Number)
    r = [zeros(3) for i in 1:N]
    
    for i in 1:N
        r_tmp = (2*rand(3).-1)
        r_tmp = r_tmp/sqrt(dot(r_tmp, r_tmp)) * rand() .* [rho_max, rho_max, z_max] 
        r[i] = r_tmp
    end

    return r
end

"""
    spherical_homogeneous_positions(N, r_max)
Create a particle distribution with `N` randomly, homogeneously distributed particles in a **spherical** shape (point symmetric around `r₀`).
The radius of the spherical distribution is specified by `r_max`. The distribution can be spatially offset using the parameter `r₀`.
"""
function spherical_homogeneous_positions(N::Int, r_max::Number)
    return spherical_homogeneous_positions(N, r_max, r_max)
end


"""
    cubic_homogeneous_positions(N, rho_max, z_max, r₀)
Create a particle distribution with `N` randomly, homogeneously distributed particles in a **spheroid** shape (with symmetry around the z axis).
The boundary of the distribution domain is specified by `rho_max` and `z_max`. The distribution can be spatially offset using the parameter `r₀`.
"""
function cubic_homogeneous_positions(N::Int, lx::Number, ly::Number, lz::Number)
    return [(rand(3).-0.5).*[lx, ly, lz] for i in 1:N]
end

function cubic_homogeneous_positions(N::Int, l::Number)
    return cubic_homogeneous_positions(N, l, l, l)
end