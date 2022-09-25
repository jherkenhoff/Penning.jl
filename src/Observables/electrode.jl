
using Penning.Electrodes
using Penning.Circuits

struct ElectrodeVoltageObservable <: AbstractScalarObservable
    trap :: Symbol
    electrode :: Symbol
end

function (obs::ElectrodeVoltageObservable)(setup::Setup)
    return setup.traps[obs.trap].electrodes[obs.trap].u
end


struct ElectrodeCurrentObservable <: AbstractScalarObservable
    trap :: Symbol
    electrode :: Symbol
end

function (obs::ElectrodeCurrentObservable)(setup::Setup)
    return setup.traps[obs.trap].electrodes[obs.trap].i
end