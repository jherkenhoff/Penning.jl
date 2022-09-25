
struct Connection{T, E, C}
    trap :: T
    electrode :: E
    circuit :: C
    circuit_pin :: Integer
end

function Connection(; trap, electrode, circuit, circuit_pin)
    return Connection(trap, electrode, circuit, circuit_pin)
end