pushfirst!(LOAD_PATH, joinpath(@__DIR__, ".."))

using Penning
using Documenter
using DocumenterCitations
using Literate

const EXAMPLES_DIR = joinpath(@__DIR__, "..", "examples")
const OUTPUT_DIR   = joinpath(@__DIR__, "src/generated")

examples = [
    "basic_eigenmotion.jl",
]

for example in examples
    example_filepath = joinpath(EXAMPLES_DIR, example)
    Literate.markdown(example_filepath, OUTPUT_DIR; flavor = Literate.DocumenterFlavor())
end

example_pages = 

pages = [
    "Home" => "index.md",
    "Getting Started" => "getting_started.md",
    "Examples" => [
        "Basic eigenmotion" => "generated/basic_eigenmotion.md",
    ],
    "Simulation setup" => [
        "Overview" => "simulation_setup/overview.md",
        "Traps" => "simulation_setup/traps.md",
        "Particles" => "simulation_setup/particles.md",
        "Particle interactions" => "simulation_setup/interactions.md",
        "Excitations" => "simulation_setup/excitations.md"
    ],
    "Running the simulation" => [
        "Overview" => "simulation/overview.md",
        "Particle integrators" => "simulation/integrators.md",
        "Distributed / parallel computing" => "simulation/distributed_parallel.md",
    ],
    "Output writers" => [
        "Overview" => "output_writers/overview.md"
        "Writing to memory" => "output_writers/memory_writer.md"
    ],
    "Circuit cosimulation" => [
        "Overview" => "circuit_cosimulation/overview.md",
        "Theory" => "circuit_cosimulation/theory.md"
    ],
    "Utils" => [
        "Schedules" => "utils/schedules.md"
    ],
]

format = Documenter.HTML(
    collapselevel = 1,
    prettyurls = get(ENV, "CI", nothing) == "true",
    canonical = "https://github.com/jherkenhoff/Penning.jl",
    mathengine = MathJax3()
)

#format = Documenter.LaTeX()

makedocs(
         sitename = "Penning.jl",
         authors = "Jost Herkenhoff",
         format = format,
         modules  = [Penning],
         pages = pages
)

deploydocs(;
    repo="github.com/jherkenhoff/Penning.jl"
)