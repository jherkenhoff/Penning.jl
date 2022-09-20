# From https://github.com/CliMA/Oceananigans.jl/blob/main/src/OutputWriters/output_writer_utils.jl

"""
auto_extension(filename, ext)                                                             
If `filename` ends in `ext`, return `filename`. Otherwise return `filename * ext`.
"""
function auto_extension(filename, ext) 
    Next = length(ext)
    filename[end-Next+1:end] == ext || (filename *= ext)
    return filename
end