using Penning.Circuits

using Plots, DifferentialEquations
using ModelingToolkit
R = 10
C = 1.0
L = 1.0
@named resistor = Resistor(R=R)
@named inductor = Inductor(L=L)
@named capacitor = Capacitor(C=C)
@named ground = Ground()

rcl_eqs = [
          connect(resistor.p, inductor.p, capacitor.p)
          connect(resistor.n, inductor.n, capacitor.n, ground.g)
         ]

@named _rcl_model = ODESystem(rcl_eqs, t)
@named rcl_model = compose(_rcl_model, [resistor, inductor, capacitor, ground])
sys = structural_simplify(rcl_model)
u0 = [ capacitor.v => 1.0, inductor.i => 0.0 ]
prob = ODAEProblem(sys, u0, (0, 10.0))
sol = solve(prob, Tsit5())
plot(sol)