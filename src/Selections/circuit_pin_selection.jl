using Penning.Setups

struct CircuitPinSelection{C} <: AbstractCircuitPinSelection
    circuit :: C
    pin :: Int64
end

function CircuitPinSelection(;circuit, pin)
    return CircuitPinSelection(circuit, pin)
end

function get_circuit_pin_selection_voltage(s::CircuitPinSelection, setup::Setup)
    return setup.circuits[s.circuit].u[s.pin]
end

function get_circuit_pin_selection_current(s::CircuitPinSelection, setup::Setup)
    return setup.circuits[s.circuit].i[s.pin]
end

function set_circuit_pin_selection_voltage!(s::CircuitPinSelection, setup::Setup, u::Number)
    setup.circuits[s.circuit].u[s.pin] = u
    nothing
end

function set_circuit_pin_selection_current!(s::CircuitPinSelection, setup::Setup, i::Number)
    setup.circuits[s.circuit].i[s.pin] = i
    nothing
end

function add_circuit_pin_selection_voltage!(s::CircuitPinSelection, setup::Setup, u::Number)
    setup.circuits[s.circuit].u[s.pin] += u
    nothing
end

function add_circuit_pin_selection_current!(s::CircuitPinSelection, setup::Setup, i::Number)
    setup.circuits[s.circuit].i[s.pin] += i
    nothing
end