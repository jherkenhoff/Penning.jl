pushfirst!(LOAD_PATH, joinpath(@__DIR__, ".."))

using Penning
using Documenter
using DocumenterCitations
using Literate

const EXAMPLES_DIR = joinpath(@__DIR__, "..", "examples")
const EXAMPLES_OUTPUT_DIR   = joinpath(@__DIR__, "src/generated/examples")
const VALIDATION_DIR = joinpath(@__DIR__, "..", "studies/validation")
const VALIDATION_OUTPUT_DIR   = joinpath(@__DIR__, "src/generated/validation")

examples = [
    "basic_eigenmotion.jl",
]

for example in examples
    example_filepath = joinpath(EXAMPLES_DIR, example)
    Literate.markdown(example_filepath, EXAMPLES_OUTPUT_DIR; flavor = Literate.DocumenterFlavor())
end


validations = [
    "ion_detection/resistor_noiseless.jl",
]

for validation in validations
    validation_filepath = joinpath(VALIDATION_DIR, validation)
    Literate.markdown(validation_filepath, VALIDATION_OUTPUT_DIR; flavor = Literate.CommonMarkFlavor())
end

# copy some figures to the build directory
cp(joinpath(VALIDATION_DIR, "ion_detection/resistor_noiseless.png"),
   joinpath(VALIDATION_OUTPUT_DIR, "resistor_noiseless.png"); force = true)

pages = [
    "Home" => "index.md",
    "Getting Started" => "getting_started.md",
    "Examples" => [
        "Basic eigenmotion" => "generated/examples/basic_eigenmotion.md",
    ],
    "Setting up the simulation" => [
        "Overview" => "simulation_setup/overview.md",
        "Traps" => "simulation_setup/traps.md",
        "Fields" => "simulation_setup/fields.md",
        "Particles" => "simulation_setup/particles.md",
        "Particle interactions" => "simulation_setup/interactions.md",
        "Detection electrodes" => "simulation_setup/electrodes.md",
    ],
    "Running the simulation" => [
        "Overview" => "simulation/overview.md",
        "Particle integrators" => "simulation/integrators.md",
        "Distributed / parallel computing" => "simulation/distributed_parallel.md",
        "Observables" => "simulation/observables.md",
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
    "Validation studies" => [
        "Ion detection" => [
            "Noiseless Resistor" => "generated/validation/resistor_noiseless.md",
        ]
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