module Bessel

export besselj_zero, besseljp_zero, besselj, besseljp

using DelimitedFiles
using SpecialFunctions

import Penning
DATA_DIR = joinpath(pkgdir(Penning), "data")

const besselj_zeros = readdlm(joinpath(DATA_DIR, "besselj_zeros.txt"))
const besseljp_zeros = readdlm(joinpath(DATA_DIR, "besseljp_zeros.txt"))

function besselj_zero(nu, n)
    return besselj_zeros[nu+1, n]
end

function besseljp_zero(nu, n)
    return besseljp_zeros[nu+1, n]
end

function besseljp(nu, x)
    # https://www.boost.org/doc/libs/1_57_0/libs/math/doc/html/math_toolkit/bessel/bessel_derivatives.html
    return (besselj(nu-1, x) - besselj(nu+1, x))/2
end


end # module