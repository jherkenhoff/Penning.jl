
function Resistor(R::Number; T::Number=0.0)

    a(x) = []
    b(i) = []
    c(x) = [0.0]
    d(i) = [R*i[1]]
    xn() = []
    un() = [sqrt(2*k_B*T*R)]

    x₀ = Vector{Float64}(undef, 0)
    return Circuit([0.0], [0.0], a, b, c, d, xn, un, x₀)
end
