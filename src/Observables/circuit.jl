using Penning.Circuits
using Penning.Selections

"""
    CircuitPinVoltageObservable()
Defines an observable that returns the voltage (in volt) of a specific pin of a circuit.
"""
struct CircuitPinVoltageObservable <: AbstractScalarObservable
end

function observe(observable::CircuitPinVoltageObservable, selection::AbstractCircuitPinSelection, setup::Setup)
    return get_circuit_pin_selection_voltage(selection, setup)
end


"""
    CircuitPinCurrentObservable()
Defines an observable that returns the current (in ampere) of a specific pin of a circuit.
"""
struct CircuitPinCurrentObservable <: AbstractScalarObservable
end

function observe(observable::CircuitPinCurrentObservable, selection::AbstractCircuitPinSelection, setup::Setup)
    return get_circuit_pin_selection_current(selection, setup)
end