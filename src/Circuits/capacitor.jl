
function Capacitor(C::Number; V₀::Number=0.0)

    a(x) = [0]
    b(i) = i./C
    c(x) = x
    d(i) = [0]
    xn() = [0]
    un() = [0]

    x₀ = [V₀]
    return Circuit([0.0], [0.0], a, b, c, d, xn, un, x₀)
end
