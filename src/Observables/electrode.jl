
using Penning.Electrodes
using Penning.Circuits
using Penning.Selections

"""
    ElectrodeVoltageObservable()
Defines an observable that returns the voltage (in volts) of an electrode.
"""
struct ElectrodeVoltageObservable <: AbstractScalarObservable
end

function observe(observable::ElectrodeVoltageObservable, selection::AbstractElectrodeSelection, setup::Setup)
    return get_electrode_selection_voltage(selection, setup)
end



"""
    ElectrodeCurrentObservable()
Defines an observable that returns the current (in amperes) of an electrode.
"""
struct ElectrodeCurrentObservable <: AbstractScalarObservable
end

function observe(observable::ElectrodeCurrentObservable, selection::AbstractElectrodeSelection, setup::Setup)
    return get_electrode_selection_current(selection, setup)
end