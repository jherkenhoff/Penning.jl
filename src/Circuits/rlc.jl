
function Resistor(;name, R=1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    ps = @parameters R=R
    eqs = [
           v ~ i * R
          ]
    extend(ODESystem(eqs, t, [], ps; name=name), oneport)
end

function NoisyResistor(;name, R=1.0, T=300.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    ps = @parameters R=R T=T V_noise=0.0
    eqs = [
           v ~ i * R + V_noise
          ]
    extend(ODESystem(eqs, t, [], ps; name=name), oneport)
end

function Inductor(;name, L = 1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    ps = @parameters L=L
    D = Differential(t)
    eqs = [
           D(i) ~ v / L
          ]
    extend(ODESystem(eqs, t, [], ps; name=name), oneport)
end


function Capacitor(;name, C = 1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    ps = @parameters C=C
    D = Differential(t)
    eqs = [
           D(v) ~ i / C
          ]
    extend(ODESystem(eqs, t, [], ps; name=name), oneport)
end
