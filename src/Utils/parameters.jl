import Base: +

abstract type AbstractParameter end


"""
    ConstantParameter(value)
A parameter that always returns a constant value defined by `value`.
"""
struct ConstantParameter{T} <: AbstractParameter
    value::T
end

function (param::ConstantParameter)(t::Number)
    return param.value
end


"""
    LinearDriftParameter(drift)
A parameter whose value drifts linearly with time at a rate defined by `drift` in 1/s.
"""
struct LinearDriftParameter{T} <: AbstractParameter
    drift::T
end

function (param::LinearDriftParameter)(t::Number)
    return param.drift * t
end



mutable struct GaussianNoiseParameter <: AbstractParameter
    sigma :: Float64
    dt :: Float64
    last_t :: Float64
    last_v :: Float64
end

function GaussianNoiseParameter(sigma::Number, dt::Number)
    return GaussianNoiseParameter(sigma, dt, -Inf, sigma/sqrt(dt)*randn())
end

function (param::GaussianNoiseParameter)(t::Number)
    if t != param.last_t
        param.last_t = t
        param.last_v = param.sigma/sqrt(param.dt)*randn()
    end
    return param.last_v
end



# Composition parameters
"""
    AddParameter(param_a, param_b)
A parameter that returns the sum of two parameters `param_a` and `param_b`. The `+` 
operator is overloaded so that a [AddParameter](@ref) is automatically created
when two [AbstractParameter](@ref) are added together.
"""
struct AddParameter{A, B} <: AbstractParameter
    param_a::A
    param_b::B
end

function (param::AddParameter)(t::Number)
    return param.param_a(t) + param.param_b(t)
end

function (+)(a::AbstractParameter, b::AbstractParameter)
    return AddParameter(a, b)
end