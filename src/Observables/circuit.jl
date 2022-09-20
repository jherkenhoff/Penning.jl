
using Penning.Electrodes
using Penning.Circuits

struct ElectrodeVoltageObservable <: AbstractScalarObservable
    trap :: Symbol
    electrode :: Symbol
end

function (obs::ElectrodeVoltageObservable)(setup::Setup)

    i_dict = Dict{Tuple{Symbol, Symbol}, Float64}()
    for (electrode_key, electrode) in setup.traps[obs.trap].electrodes
        i_dict[obs.trap, electrode_key] = 0.0
        for p in values(setup.traps[obs.trap].particles)
            i_dict[obs.trap, electrode_key] += sum(calc_electrode_induced_current.((electrode,), p.r, p.v, (p.species.q,)))
        end
    end

    u_dict = get_circuit_electrode_voltages(setup.circuit, i_dict)
    return u_dict[obs.trap, obs.electrode]
end