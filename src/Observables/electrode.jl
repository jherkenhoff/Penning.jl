
using Penning.Electrodes
using Penning.Circuits
using Penning.Selections

struct ElectrodeVoltageObservable <: AbstractScalarObservable
    electrode_seleciton :: AbstractElectrodeSelection
end

function (obs::ElectrodeVoltageObservable)(setup::Setup)
    return get_electrode_selection_voltage(obs.electrode_seleciton, setup)
end


struct ElectrodeCurrentObservable <: AbstractScalarObservable
    trap :: Symbol
    electrode :: Symbol
end

function (obs::ElectrodeCurrentObservable)(setup::Setup)
    return setup.traps[obs.trap].electrodes[obs.trap].i
end