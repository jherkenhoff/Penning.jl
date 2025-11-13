
struct Trap{F, P, I, E}
    particles::Particles
    fields :: F
    interactions :: I
    electrodes :: E
end

"""
    Trap(particles; fields=(;), interactions=(;), electrodes=(;))
"""
function Trap(particles::Particles; fields=(;), interactions=(;), electrodes=(;))
    return Trap(particles, fields, interactions, electrodes)
end