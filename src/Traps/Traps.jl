module Traps

export Trap

struct Trap{F, P, I, E}
    fields :: F
    particles :: P
    interactions :: I
    electrodes :: E
end

function Trap(;fields=(;), particles=(;), interactions=(;), electrodes=(;))
    return Trap(fields, particles, interactions, electrodes)
end

end # module