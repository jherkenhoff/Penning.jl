
using DifferentialEquations

using Penning.Constants

struct Circuit <: AbstractCircuit
      components::Vector{ODESystem}
      model::ODESystem
      prob::ODEProblem
      integrator
end

function Circuit(connections::Vector{Equation}, components::Vector{ODESystem}; solver=Tsit5())
      @named _model = ODESystem(connections, t)
      @named model = compose(_model, components)
      simplified_model = structural_simplify(model)

      u0 = (length(equations(simplified_model)) == 0) ? [1] : [] # HACK: For very simple models (e.g. a plain resistor), the model has no differential equations. To prevent init() from throwing an error, we act as if we have an equation by forcing the initial value u0 to have an arbitrary entry, which however is never used...
      prob = ODAEProblem(simplified_model, u0, (0, Inf))
      integrator = init(prob, solver, save_on=false, maxiters=Inf)

      return Circuit(components, simplified_model, prob, integrator)
end

function update_circuit_electrode_current!(circuit::Circuit, electrode_pin::ODESystem, current::Number)
      i = findfirst(isequal(electrode_pin.i_induced), parameters(circuit.model))
      circuit.integrator.p[i] = current
end

function step_circuit!(circuit::Circuit, dt::Float64)
      # TODO: Add noise here
      for component in circuit.components
            if "V_noise" in [string(p) for p in parameters(component)]
                  # HACK: We simply assume that the component has parameters R and T (sincy currently the only component with V_noise is the NoisyResistor. However, this might change in the future)
                  i = findfirst(isequal(component.R), parameters(circuit.model))
                  R = circuit.integrator.p[i]
                  i = findfirst(isequal(component.T), parameters(circuit.model))
                  T = circuit.integrator.p[i]

                  # Calculate noise: https://workarea.et-gw.eu/et/WG4-Astrophysics/codes/noiseanalysis.pdf
                  V_noise = sqrt(2*k_B*T*R/dt)*randn()

                  i = findfirst(isequal(component.V_noise), parameters(circuit.model))
                  circuit.integrator.p[i] = V_noise
            end
      end


      step!(circuit.integrator, dt, true)

      # HACK: Write current state into solution
      circuit.integrator.sol.u[1] = circuit.integrator.u
      circuit.integrator.sol.t[1] = circuit.integrator.t
end

function get_circuit_electrode_voltage(circuit::Circuit, electrode_pin::ODESystem)
      return circuit.integrator.sol[electrode_pin.v][1]
end

# rcl_eqs = [
#           connect(resistor.p, inductor.p, capacitor.p)
#           connect(resistor.n, inductor.n, capacitor.n, ground.g)
#          ]

# @named _rcl_model = ODESystem(rcl_eqs, t)
# @named rcl_model = compose(_rcl_model,
#                           [resistor, inductor, capacitor, ground])
# sys = structural_simplify(rcl_model)
# u0 = [
#       capacitor.v => 1.0,
#       inductor.i => 0.0,
#      ]
# prob = ODAEProblem(sys, u0, (0, 10.0))
# sol = solve(prob, Tsit5())
# plot(sol)


# integrator = init(prob, Tsit5())

# step!(integrator)

# integrator.t
# integrator.p

# indexof(sym, syms) = findfirst(isequal(sym),syms)
# indexof(capacitor.C, parameters(sys))


# integrator.p[1] = Inf


# integrator.sol

# plot(integrator.sol)