using UUIDs
using LinearAlgebra

mutable struct ParallelPlateElectrode <: AbstractElectrode
    D :: Vector{<:Number}
    i :: Float64
    u :: Float64
end

function ParallelPlateElectrode(D::Vector{<:Number})
    return ParallelPlateElectrode(D, 0.0, 0.0)
end

AxialParallelPlateElectrode(D) = ParallelPlateElectrode([Inf, Inf, D])
XParallelPlateElectrode(D) = ParallelPlateElectrode([D, Inf, Inf])
YParallelPlateElectrode(D) = ParallelPlateElectrode([Inf, D, Inf])
RadialParallelPlateElectrode(D) = XParallelPlateElectrode(D)

function calc_electrode_induced_current(electrode::ParallelPlateElectrode, r::AbstractVector{<:Number}, v::AbstractVector{<:Number}, q::Number)
    return sum(q .* v ./ electrode.D)
end

function calc_electrode_backaction_field(electrode::ParallelPlateElectrode, r::AbstractVector{<:Number})
    return -electrode.u ./ electrode.D
end

function calc_electrode_PE(electrode::ParallelPlateElectrode, r::AbstractVector{<:Number}, q::Number)
    E = -electrode.u ./ electrode.D
    V = dot(E, r) # Electrical potential
    return q*V
end