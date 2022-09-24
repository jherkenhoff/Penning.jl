using Penning.Constants

"""
    Species
Parameter object for spcifying the mass `m` (in kg) and the charge `q` (in C) of a particle species.
"""
struct Species
    m :: Float64
    q :: Float64
end

"""
    Electron()
Predefined particle species for the electron
"""
Electron() = Species(m_e, -e)

"""
    Ion(m, q)
Function for generating a particle species using units commonly used in atomic physics:
Mass `m` is provided in atomic mass units and charge `q` is provided in units of (positive) elementary charge.

# Example:
The following instantiates an ion with mass 187 u and charge state 28+
```
my_ion = Ion(187, 28)
```
"""
function Ion(m::Number, q::Number)
    Species(m*m_u, q*e)
end