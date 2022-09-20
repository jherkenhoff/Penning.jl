# Writing to memory

In many cases, it might be helpful to keep a "history" of certain variables of a simulation inside the main memory (RAM).
This allows to perform data analysis in Julia right after finishing the simulation, without having to store the data in an intermediate file on disk (which might also slow down your simulation).

!!! info
    When executing long running simulations or storing big chunks of data per write-iteration, you might want to keep an eye on memory utilization.

## `MemoryWriter`
``` @docs
MemoryWriter(::Function, ::Penning.OutputWriters.Utils.AbstractSchedule)
```

## `PositionMemoryWriter`
``` @docs
PositionMemoryWriter(::Symbol, ::Symbol, ::Penning.Utils.AbstractSchedule)
```

## `CircuitMemoryWriter`
``` @docs
CircuitMemoryWriter(observable, ::Penning.Utils.AbstractSchedule)
```


