# # Basic eigenmotion example
#
# In this example, we are going to simulate the motion of a single ion stored inside 
# a Penning trap. This example can be considered as the *hello world* of `Penning.jl`.
# You will learn how to:
#  * Set up a simple simulation with one ion in an ideal Penning trap
#  * Store simulation data (in this case the position of the ion) to memory
#  * Access the simulation data
#  * Plot the simulated ion motion
#
# ## Install dependencies
#
# First let's make sure we have all required packages installed.

# ```julia
# using Pkg
# pkg"add Penning, Plots"
# ```

# ## Import dependencies
#
# In order to use the functionality of `Penning.jl`, we have to tell Julia
# that we want to use this package. While we are at it, lets also import the
# [Plots](https://docs.juliaplots.org/latest/) package:

using Penning
using Penning.Constants
using Plots

# ## Define trap parameters
# 
# Define some trap parameters for the ideal trap.
# As you can see, the names of the constants contain unicode characters, which are
# nice to read, but may seem hard to type at first glance.
# However, if you are a Julia developer, chances are high that you are using
# [Visual Studio Code](https://code.visualstudio.com/) with the 
# [Julia extension](https://code.visualstudio.com/docs/languages/julia), which makes
# typing unicode characters a breeze: You just have to type `U\_0` and hit enter or tab
# and VS Code will add the correct unicode symbol.

const U₀ = -50.0
const c₂ = -14960.0
const B₀ = 1.0

# ## Instantiate trap
#
# The [`Trap`](@ref) object contains all things related to a single Penning trap.
# In this example, we are using an [`IdealTrapField`](@ref) with the previously 
# specified parameters.
# For more complex simulations, this is the place where you would also add 
# for example excitation fields or field imperfections.
#
# Since an empty trap would be quite boring, we have to specify the particles that should 
# take part in the simulation.
# `Penning.jl` groups particles of the same particle species into [`ParticleCollection`](@ref)s, which
# is a concept that becomes important if you want to specify and control inter-particle interactions.
# But since we only want to simulate a single ion we only need a single particle collection.
# In this example, we are using an ion with mass 187 u (atomic mass unit) and charge state
# +30 (in elementary charge unit).
# The initial position and velocity have to be specified in meters and meters per second, respectively.

trap = Trap(
    particles = Particles(hcat([[50e-6, 0, 50e-6]]...), hcat([[100.0, 0.0, 0.0]]...), [30*q_e], [187*m_u]),
    fields = [
        IdealTrapField(U₀, c₂, B₀)
    ]
)

# ## Instantiate setup
#
# The following code instantiates a [`Setup`](@ref) object, which contains all
# "subsystems" that should be included in this simulation setup.
# In this example, we only want to simulate our previously instantiated trap, 
# but in more complex simulations this would be the place where you would for example
# add multiple traps, add electrical circuits and specify their connections.

setup = Setup(
    traps = [trap]
)

# ## Instantiate simulation object
# 
# The [`Simulation`](@ref) object contains a single reference to a [`Setup`](@ref)
# object and is otherwise responsible for  storing information about how the simulation
# is performed. Here, we specify that we want to use a time step (`dt`) of 20 ns and 
# specify which data we want to save during simulation.
# In `Penning.jl`, data is stored using "output writers", which offers various "data storage backends".
# In this case we are using a [`MemoryWriter`](@ref), which stores data into
# system memory (RAM).
#
# The code `PositionObservable()` tells our MemoryWriter that we want to store
# the position of a particle. The code `SingleParticleSelection` selects the particle of which we want
# to save the position. (Note that the first index in Julia is 1, not 0)
#
# The code `IterationInterval(1)` specifies the times at which the specified observable
# is to be saved. In this case, we want to store data at every simulation iteration.

sim = Simulation(
    setup,
    dt=20e-9,
    output_writers = [
        MemoryWriter(
            PositionObservable(),
            ParticleSelection(trap=1, particle_index=1),
            IterationInterval(1)
        )
    ]
)

# ## Run simulation
#
# Its finally time to run the simulation!
# Just specify how long you want to simulate and lean back (but not for too long - `Penning.jl` is fast 😉).
# This particular simulation will probably finish in way under one second. Note that
# Julia is a just in time (JIT) compiled language, and might take a while to initially
# compile the code before actually running it. For further information on how Julia
# executes code, you might want to take a look [here](https://docs.julialang.org/en/v1/devdocs/eval/).
#
# The following [`run!`](@ref) command runs the simulation until the time
# of 10 µs is reached. Note that this is the time **within your simulation** and 
# not the "real-life time" (also called [wall-time](https://en.wikipedia.org/wiki/Elapsed_real_time)) 
# that it takes your computer to run.
# Take a look at the documentation of [`run!`](@ref) for further information on stop conditions.

run!(sim, SimTimeStopCondition(10e-6))

# ## Retreive simulation data
#
# Data stored inside a [`MemoryWriter`](@ref) can be accessed in the following way:

r = sim.output_writers[1].mem
t = sim.output_writers[1].t

x = getindex.(r, 1)
y = getindex.(r, 2)
z = getindex.(r, 3)

plot(t*1e6, z*1e6, legend=false)
xlabel!("\$t\$ / ms")
ylabel!("Axial position / µm")
savefig(joinpath(@__DIR__, "img/basic_eigenmotion_z.png"))


plot(t*1e6, x*1e6, legend=false)
xlabel!("\$t\$ / ms")
ylabel!("X position / µm")
savefig(joinpath(@__DIR__, "img/basic_eigenmotion_x.png"))

# ## Results
# ![](img/basic_eigenmotion_z.png)
# ![](img/basic_eigenmotion_x.png)