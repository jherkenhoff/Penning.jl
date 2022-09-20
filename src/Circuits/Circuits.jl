module Circuits

export 
    AbstractCircuit,
    SSCircuit,
    SSCircuitResistor,
    SSCircuitResonator,
    step_circuit!,
    get_circuit_output_voltage,
    update_circuit_electrode_current!


abstract type AbstractCircuit end

#include("rlc.jl")
#include("sources.jl")
include("ss_circuit.jl")
#include("circuit.jl")

end # module