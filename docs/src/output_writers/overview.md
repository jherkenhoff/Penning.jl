# Output writers overview

Penning.jl provides various output mechanisms that can be readily used to save the state or derived variables of a simulation.

## Schedules
All output writers accept a `schedule` argument, which specifies at which point in time the output should be saved. The available schedule-implementations are defined in the [Schedules](@ref) documentation.

## Registering output writers
In order for the output writers to be executed during the simulation, they must be registered to the [`Simulation`](@ref) instance:
```
sim = Simulation(...)
sim.output_writers[:electron_position] = PositionMemoryWriter(...)
```
In this example the output writer was registered under the name/symbol `:electron_position`.