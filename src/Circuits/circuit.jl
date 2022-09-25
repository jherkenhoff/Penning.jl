
using Penning.Electrodes
using Penning.Constants: k_B

# https://upload.wikimedia.org/wikipedia/commons/e/eb/Typical_State_Space_model.svg
mutable struct Circuit
    i :: Vector{Float64} # Input current vector
    u :: Vector{Float64} # Output current vector
    a :: Function # Feedback function
    b :: Function # Input function
    c :: Function # Output function
    d :: Function # Feedthrough function
    xn :: Function # Noise added on state
    un :: Function # Noise added on output
    x :: Vector{Float64}
end

function step_circuit!(circuit::Circuit, dt::Float64)
    # Update internal state
    xn = circuit.xn()/sqrt(dt)*randn()

    # RK4:
    b = circuit.b(circuit.i)
    k1 = circuit.a(circuit.x) + b + xn
    k2 = circuit.a(circuit.x + dt*k1/2) + b + xn
    k3 = circuit.a(circuit.x + dt*k2/2) + b + xn
    k4 = circuit.a(circuit.x + dt*k3) + b + xn

    circuit.x .+= (k1+2*k2+2*k3+k4)/6*dt

    # Calculate noise: https://workarea.et-gw.eu/et/WG4-Astrophysics/codes/noiseanalysis.pdf
    
    un = circuit.un()/sqrt(dt)*randn()
    circuit.u = circuit.d(circuit.i) + circuit.c(circuit.x) + un
end

function CircuitResistor(R::Number; T::Number=0.0)

    a(x) = []
    b(i) = []
    c(x) = [0.0]
    d(i) = [R*i[1]]
    xn() = []
    un() = [sqrt(2*k_B*T*R)]

    x₀ = Vector{Float64}(undef, 0)
    return Circuit([0.0], [0.0], a, b, c, d, xn, un, x₀)
end


function CircuitResonator(R::Number, L::Number, C::Number, electrode_keys::Vector{Tuple{Symbol, Symbol}}=[]; T::Number=0.0)

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
