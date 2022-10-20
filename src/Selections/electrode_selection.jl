using Penning.Setups

struct ElectrodeSelection{T, E} <: AbstractElectrodeSelection
    trap :: T
    electrode :: E
end

function ElectrodeSelection(;trap, electrode)
    return ElectrodeSelection(trap, electrode)
end

function get_electrode_selection_voltage(s::ElectrodeSelection, setup::Setup)
    return setup.traps[s.trap].electrodes[s.electrode].u
end

function get_electrode_selection_current(s::ElectrodeSelection, setup::Setup)
    return setup.traps[s.trap].electrodes[s.electrode].i
end

function set_electrode_selection_voltage!(s::ElectrodeSelection, setup::Setup, u::Number)
    setup.traps[s.trap].electrodes[s.electrode].u = u
    nothing
end

function set_electrode_selection_current!(s::ElectrodeSelection, setup::Setup, i::Number)
    setup.traps[s.trap].electrodes[s.electrode].i = i
    nothing
end