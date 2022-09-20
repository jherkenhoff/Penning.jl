
function ConstantVoltage(;name, V = 1.0)
    @named oneport = OnePort()
    @unpack v = oneport
    ps = @parameters V=V
    eqs = [
           V ~ v
          ]
    return extend(ODESystem(eqs, t, [], ps; name=name), oneport)
end

function ConstantCurrent(;name, I = 1.0)
    @named oneport = OnePort()
    @unpack v, i = oneport
    ps = @parameters I=I
    eqs = [
           I ~ i
          ]
    return extend(ODESystem(eqs, t, [], ps; name=name), oneport)
end