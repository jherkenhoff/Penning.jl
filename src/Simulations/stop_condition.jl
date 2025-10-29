
abstract type AbstractStopCondition end

struct WallTimeStopCondition <: AbstractStopCondition
    time_ns :: Float64
end

WallTimeStopCondition(time_s::Number) = WallTimeStopCondition(time_s*1e9)

function (condition::WallTimeStopCondition)(sim::Simulation)
    should_stop = sim.wall_time_ns > condition.time_ns
    stop_reason = should_stop ? "Wall time ($(prettytime(sim.wall_time_ns/1e9))) exceeds stop condition ($(prettytime(condition.time_ns/1e9)))." : ""
    return should_stop, stop_reason
end