using Random

function boltzman_velocities(N::Int, T::Number)
    return [randn(3)*100 for i in 1:N]
end