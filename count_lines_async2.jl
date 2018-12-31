
function count_lines(buf, from = 1, nb = length(buf) )
    eol = Int('\n')
    lines = 0
    to = min(from + nb - 1, length(buf))
    for i = from:to
        @inbounds if buf[i] == eol
            lines += 1
        end
    end
    return lines
end


function read_file_by_buffer(path, buffer_size)
    fh = open(path)
    buffer = Array{UInt8}(undef, buffer_size)
    read = 0
    total = 0
    while (read = readbytes!(fh, buffer)) > 0
        resize!(buffer, read)
        total += read
   end
   close(fh)
   return total
end

function count_lines_from_channel(chnl)
    total = 0
    for buf in chnl
        total += count_lines(buf)
        flush(stdout)
    end
    return total
end

function count_lines_async(path, buffer_size = 64000)
    chnl = Channel{Array{UInt8}}(0)

    @async read_file_by_buffer(path, chnl, buffer_size)
    nb = count_lines_from_channel(chnl)

    return nb
end


path = "worldcitiespop.txt"
the_size = stat(path).size

function screen_buffer_size(path, replicates = 10)
    the_size = stat(path).size
    nmax = Int(floor(log2(the_size)))
    bests = Array{Float64}(undef, nmax)
    elapsed_min = Inf
    elapsed_current = Inf

    prog = Progress(nmax, 1)
    for n = 1:nmax
        elapsed_min = Inf
        for i = 1:replicates
            elapsed_current = @elapsed read_file_by_buffer(path, 2^n)
            elapsed_min = min(elapsed_min, elapsed_current)
        end
        bests[n] = elapsed_min
        next!(prog)
    end
    return bests
end


using Plots, ProgressMeter
elapseds = screen_buffer_size(path)

# remove first 5 results for readability
y = elapseds[5:length(elapseds)]
x = 5:length(elapseds)
gr()
plot(x, y, seriestype=:scatter)
print(minimum(y))

best = x[argmin(y)]
buffer_size = 2^best

@time read_file_by_buffer(path, 2^21)
@time read_file_by_buffer(path, 2^12)
"""
conclusion: the best buffer size is high: 2^21 ~ 2,097,152
a good smaller buffer size is 2^12 == 4,096
The minimum time is ~ 12 ms
"""



### read and process file using 2 buffers

function count_lines_async_2buffers(path, buffer_size = 4096)
    fh = open(path)
    buffers = (Array{UInt8}(undef, buffer_size), Array{UInt8}(undef, buffer_size))

    # read first buffer
    i = 1
    total = 0
    read = readbytes!(fh, buffers[i])
    if read == 0
        return total
    end
    resize!(buffers[i], read)

    while true
        @sync begin
            # process already read buffer
            @async total += count_lines(buffers[i])
            # while reading the next one
            @async begin
                read = readbytes!(fh, buffers[3 - i])
                resize!(buffers[3 - i], read)
            end
        end
        if read == 0
            break
        end
        # switch buffers
        i = 3 - i
    end

    close(fh)
    return total
end

@time count_lines_async_2buffers(path)

@time count_lines_async_2buffers(path, 2^26)
@time count_lines_async_2buffers(path, 2^12)

@time count_lines_async_2buffers(path, 2^20)


function screen_async2_buffer_size(path, nmin = 10, replicates = 10)
    the_size = stat(path).size
    nmax = Int(floor(log2(the_size)))
    bests = Array{Float64}(undef, nmax)
    elapsed_min = Inf
    elapsed_current = Inf

    prog = Progress(nmax, 1)
    for n = 1:nmax
        elapsed_min = Inf
        if (n < nmin)
            bests[n] = Inf
            continue
        end
        for i = 1:replicates
            elapsed_current = @elapsed count_lines_async_2buffers(path, 2^n)
            elapsed_min = min(elapsed_min, elapsed_current)
        end
        bests[n] = elapsed_min
        next!(prog)
    end
    return bests
end

using Plots, ProgressMeter
elapseds = screen_async2_buffer_size(path)

# remove first 5 results for readability
y = elapseds[5:length(elapseds)]
x = 5:length(elapseds)
gr()
plot(x, y, seriestype=:scatter)
print(minimum(y))

best = x[argmin(y)]
buffer_size = 2^best
