
struct Connection{T, E, C}
    trap :: T
    electrode :: E
    circuit :: C
    pin :: Integer
end

function Connection(; trap, electrode, circuit, pin)
    return Connection(trap, electrode, circuit, pin)
end