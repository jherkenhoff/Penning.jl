using ModelingToolkit, Plots, DifferentialEquations, LinearAlgebra
using Symbolics: scalarize

@variables t
D = Differential(t)

function Particle(; name, q=1, m = 1.0, r0 = [0., 0.,0.], v0 = [0., 0.,0.])
    ps = @parameters m=m q=q
    sts = @variables r[1:3](t)=r0 v[1:3](t)=v0
    eqs = scalarize(D.(r) .~ v)
    ODESystem(eqs, t, [pos..., v...], ps; name)
end