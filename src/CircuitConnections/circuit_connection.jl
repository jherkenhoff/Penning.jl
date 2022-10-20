using Penning.Selections
using Penning.Setups

struct CircuitConnection{E<:AbstractElectrodeSelection, C<:AbstractCircuitPinSelection}
    electrode_selection :: E
    circuit_pin_selection :: C
end

function CircuitConnection(;electrode_selection::AbstractElectrodeSelection, circuit_pin_selection::AbstractCircuitPinSelection)
    return CircuitConnection(electrode_selection, circuit_pin_selection)
end

function connect_electrodes_to_circuit!(c::CircuitConnection, setup::Setup)
    i = get_electrode_selection_current(c.electrode_selection, setup)
    set_circuit_pin_selection_current!(c.circuit_pin_selection, setup, i)
    nothing
end

function connect_circuit_to_electrodes!(c::CircuitConnection, setup::Setup)
    u = get_circuit_pin_selection_voltage(c.circuit_pin_selection, setup)
    set_electrode_selection_voltage!(c.electrode_selection, setup, u)
    nothing
end