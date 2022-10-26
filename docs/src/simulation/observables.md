# Observables

Observables are heavily used in Output writers.

Various parts of `Penning.jl` (e.g. [Output writers](@ref) or callbacks) need to execute certain actions at specific time intervals. For that, a family of schedules were introduced that cover a variety of basic scheduling tasks:
- [`PositionObservable`](@ref)
- [`VelocityObservable`](@ref)
- [`KineticEnergyObservable`](@ref)

Additionally, there are **[Higher-order observables](@ref)**, which are not associated to a specific physical quantity, but perform reducing or extraction operations on child observables. For example, you can use a [`SumObservable`](@ref) to observe the sum over all 
- [`VectorComponentObservable`](@ref)

## The `observe` function
``` @docs
observe
```


## `PositionObservable`
``` @docs
PositionObservable
```

## `VelocityObservable`
``` @docs
VelocityObservable
```

## `KineticEnergyObservable`
``` @docs
KineticEnergyObservable
```

## `ElectrodeObservable`
``` @docs
ElectrodeObservable
```

## Higher-order observables

### `VectorComponentObservable`
``` @docs
VectorComponentObservable
```