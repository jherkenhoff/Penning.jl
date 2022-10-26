using LinearAlgebra

"""
    VectorNormObservable(child_observable)

An observable for the L2 norm of a child vector-observable specified by `child_observable`.

# Example
For example, if you want to observe the magnitude of the velocity of a particle, you can do so
using the following code:
```
my_observable = VectorNormObservable(VelocityObservable())
v_mag = observe(my_observable, my_single_particle_selection, setup)
```
where `my_particle_selection` is a [`SingleParticleSelection`](@ref) instance.
"""
struct VectorNormObservable{O<:AbstractVectorObservable} <: AbstractSingleParticleScalarObservable
    child_observable :: O
end

function observe(observable::VectorNormObservable, selection::AbstractParticleSelection, setup::Setup)
    vec = observe(observable.child_observable, selection, setup)
    return norm(vec)
end