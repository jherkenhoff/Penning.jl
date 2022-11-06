
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

function reset_circuit_input_current!(circuit::Circuit)
    circuit.i .= 0.0
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
