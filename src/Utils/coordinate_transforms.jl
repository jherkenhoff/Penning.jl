

function cylindrical2cartesian(rho::Number, phi::Number, z::Number)
    x = rho*cos(phi)
    y = rho*sin(phi)
    return [x, y, z]
end

cylindrical2cartesian(r::AbstractVector{<:Number}) = cylindrical2cartesian(r...)

function cartesian2cylindrical(x::Number, y::Number, z::Number)
    rho = sqrt(x^2 + y^2)
    phi = atan(y, x)
    return [rho, phi, z]
end

cartesian2cylindrical(r::AbstractVector{<:Number}) = cartesian2cylindrical(r...)

function cylindrical_unit_vectors(phi::Number)
    # https://physics.stackexchange.com/questions/422163/unit-vectors-in-the-cylindrical-coordinate-system-as-functions-of-position
    e_rho = [cos(phi), sin(phi), 0]
    e_phi = [-sin(phi), cos(phi), 0]
    e_z = [0, 0, 1]
    return [e_rho, e_phi, e_z]
end