# Schedules

Various parts of `Penning.jl` (e.g. [Output writers](@ref) or callbacks) need to execute certain actions at specific time intervals. For that, a family of schedules were introduced that cover a variety of basic scheduling tasks:
- [`TimeInterval`](@ref)
- [`AlignedTimeInterval`](@ref)
- [`IterationInterval`](@ref)
- [`WallTimeInterval`](@ref)
- [`SpecifiedTimes`](@ref)

Additionally, there are "composit schedules", that link different schedules together, to build complex time dependencies:
- [`ConsecutiveIterations`](@ref)
- [`AndSchedule`](@ref)
- [`OrSchedule`](@ref)


## `TimeInterval`
``` @docs
TimeInterval(::Number)
```

## `AlignedTimeInterval`
``` @docs
AlignedTimeInterval(::Number, ::Number)
```

## `IterationInterval`
``` @docs
IterationInterval(interval)
```

## `WallTimeInterval`
``` @docs
WallTimeInterval(interval)
```

## `SpecifiedTimes`
``` @docs
SpecifiedTimes(::Vararg{<:Number})
```

## `ConsecutiveIterations`
``` @docs
ConsecutiveIterations(parent_schedule)
```

## `AndSchedule`
``` @docs
AndSchedule(schedules...)
```

## `OrSchedule`
``` @docs
OrSchedule(schedules...)
```