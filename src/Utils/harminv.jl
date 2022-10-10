using Penning.Utils

struct HarminvResult
    f::Real
    decay_const::Real
    Q::Real
    amp::Real
    phase::Real
    error::Real
end


function harminv(t::Vector{Float64}, re::Vector{Float64}, fmin::Real, fmax::Real)

    io = IOBuffer()

    dt = t[2] - t[1]

    f = open(`harminv -t $dt $fmin-$fmax`, "w", io)

    for i in 1:length(re)
        println(f, re[i])
        # println(f, "$(pos_log.r[1, particle_id, i])+$(pos_log.r[2, particle_id, i])i")  
    end

    close(f)
    sleep(2) # HACK: Wait for harminv to finish printing results. TODO: Replace with something more reliable and less time-wastefull

    seekstart(io)

    s = readline(io)
    if s != "frequency, decay constant, Q, amplitude, phase, error"
        error("Strange output from harminv")
    end

    result = Vector{HarminvResult}()

    while true
        s = readline(io)

        s == "" && break

        chunks = split(s, ", ")
        v = map((chunk) -> parse(Float64, chunk), chunks)
        single_result = HarminvResult(v...)

        # Only store harminv result if frequency is positive
        if single_result.f > 0
            push!(result, single_result)
        end
    end

    return result
end


function harminv_primary(t::Vector{Float64}, re::Vector{Float64}, fmin::Real, fmax::Real)
    harminv_results = harminv(t, re, fmin, fmax)
    
    global amp_max = 0.0
    global i_max = 0
    for (i, res) in enumerate(harminv_results)
        if res.amp >= amp_max
            global i_max = i
            global amp_max = res.amp
        end
    end

    return harminv_results[i_max]
end

function Base.show(io::IO, res::HarminvResult)
    return print(io, "Harminv Result\n",
                     "├── Frequency: $(prettyfrequency(res.f))\n",
                     "├── Decay Constant: $(res.decay_const)\n",
                     "├── Quality factor: $(res.Q)\n",
                     "├── Amplitude: $(res.amp)\n",
                     "├── Phase: $(res.phase)\n",
                     "└── Error: $(res.error)\n")
end