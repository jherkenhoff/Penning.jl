module Electrodes

export 
    AbstractElectrode,
    ParallelPlateElectrode,
    AxialParallelPlateElectrode,
    XParallelPlateElectrode,
    YParallelPlateElectrode,
    RadialParallelPlateElectrode,
    calc_electrode_induced_current,
    update_electrode_induced_current!,
    update_electrode_voltage!,
    calc_electrode_backaction_field,
    calc_electrode_PE,
    get_electrode_voltage

abstract type AbstractElectrode end

function update_electrode_voltage!(electrode::AbstractElectrode, u::Number)
    electrode.u = u
    nothing
end

function get_electrode_voltage(electrode::AbstractElectrode)
    return electrode.u
end

include("parallel_plate.jl")

end # module