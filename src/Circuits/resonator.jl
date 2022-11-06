

function Resonator(R::Number, L::Number, C::Number, electrode_keys::Vector{Tuple{Symbol, Symbol}}=[]; T::Number=0.0)

    a(x) = [
        (-x[2] - x[1]/R)/C,
        x[1]/L
    ]

    b(i_dict) = [
        sum([i_dict[key] for key in electrode_keys])/C,
        0.0
    ]

    c(x) = Dict([key => x[1] for key in electrode_keys])

    d(i_dict) = Dict()

    xn() = [
        sqrt(2*k_B*T/R),
        0.0
    ]

    yn() = Dict()

    x₀ = [0.0, 0.0]
    return Circuit(a, b, c, d, xn, yn, x₀)
end
