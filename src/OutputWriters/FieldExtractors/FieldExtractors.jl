module FieldExtractors

export VolumeExtractor


function VolumeExtractor(l::Float64; x0::Float64=0.0, y0::Float64=0.0, z0::Float64=0.0, n::Integer=50)
    return VolumeExtractor(l, l, l, x0=x0, y0=y0, z0=z0, nx=n, ny=n, nz=n)
end

function VolumeExtractor(lx::Float64, ly::Float64, lz; x0::Float64=0.0, y0::Float64=0.0, z0::Float64=0.0, nx::Integer=50, ny::Integer=50, nz::Integer=50)
    x = LinRange(-lx/2, lx/2, nx)
    y = LinRange(-ly/2, ly/2, ny)
    z = LinRange(-lz/2, lz/2, nz)

    xyz = zeros(Float64, 3, nx, ny, nz)

    for i=1:nx, j=1:ny, k=1:nz
        xyz[1, i, j, k] =  x[i]
        xyz[2, i, j, k] =  y[j]
        xyz[3, i, j, k] =  z[k]
    end

    return xyz
end

end # module