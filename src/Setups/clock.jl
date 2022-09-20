using Dates: AbstractTime, DateTime, Nanosecond, Millisecond
using Penning.Utils: prettytime

import Base: show

mutable struct Clock
    time :: Float64
    iteration :: Int
end

Clock(; time=0.0, iteration=0) = Clock(time, iteration)

Base.summary(clock::Clock) = string("Clock(time=$(prettytime(clock.time)), iteration=$(clock.iteration))")

Base.show(io::IO, c::Clock) where T =
    println(io, "Clock: time = $(prettytime(c.time)), iteration = $(c.iteration)")

next_time(clock, dt) = clock.time + dt

tick_time!(clock, dt) = clock.time += dt

function tick!(clock, dt)
    tick_time!(clock, dt)
    clock.iteration += 1
    nothing
end

function reset!(clock::Clock)
    clock.time = 0.0
    clock.iteration = 0
    nothing
end

