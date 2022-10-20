function vector_component_symbol_to_int(component::Symbol)
    if component == :x
        return 1
    elseif component == :y
        return 2
    elseif component == :z
        return 3
    else
        throw(ArgumentError("Symbol \"$(component)\" is not a valid vector-component designator. Valid symbols are :x, :y, and :z."))
    end
end



"""
    VectorComponentObservable(child_observable, component)
Defines an observable that returns a single component (x, y, or z) of a child vector-observable
specified by `child_observable`.
The component is specified by the `component` argument. Valid components are the
integers 1,2,3 or the symbols :x,:y,:z.

For example, if you only want to observe the x position of a particle, you can do so
using the following code:
```
my_observable = VectorComponentObservable(PositionObservable(), :x)
```
"""
struct VectorComponentObservable{O<:AbstractVectorObservable} <: AbstractScalarObservable
    child_observable :: O
    component :: Integer
end

function VectorComponentObservable(child_observable::AbstractVectorObservable, component::Symbol)
    i = vector_component_symbol_to_int(component)
    return VectorComponentObservable(child_observable, i)
end

function observe(observable::VectorComponentObservable, selection::AbstractSingleParticleSelection, setup::Setup)
    vec = observe(observable.child_observable, selection, setup)
    return vec[observable.component]
end

function observe(observable::VectorComponentObservable, selection::AbstractMultiParticleSelection, setup::Setup)
    vec = observe(observable.child_observable, selection, setup)
    return getindex.(vec, observable.component)
end

