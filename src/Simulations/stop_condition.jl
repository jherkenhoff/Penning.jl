
abstract type AbstractStopCondition end

struct WallTimeStopCondition <: AbstractStopCondition
    time :: Float64
end

function (condition::WallTimeStopCondition)(sim::Simulation)
    should_stop = sim.wall_time_ns > condition.time*1e9
    stop_reason = should_stop ? "Wall time ($(prettytime(sim.wall_time_ns/1e9))) exceeds stop condition ($(prettytime(condition.time)))." : ""
    return should_stop, stop_reason
end

struct SimTimeStopCondition <: AbstractStopCondition
    time :: Float64
end

function (condition::SimTimeStopCondition)(sim::Simulation)
    should_stop = sim.setup.clock.time > condition.time
    stop_reason = should_stop ? "Simulation time ($(prettytime(sim.setup.clock.time))) exceeds stop condition ($(prettytime(condition.time)))." : ""
    return should_stop, stop_reason
end