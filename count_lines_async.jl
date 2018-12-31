
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


path = "worldcitiespop.txt"

the_size = stat(path).size

function read_file_by_buffer(path, chnl, buffer_size)
    fh = open(path)
    buffer = Array{UInt8}(undef, buffer_size)
    read = 0
    while (read = readbytes!(fh, buffer)) > 0
        resize!(buffer, read)
        put!(chnl, buffer)
   end
   close(chnl)
   close(fh)
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

@time count_lines_async(path, the_size)
# 0.07s
@time count_lines_async(path, Int(round(the_size/4)))
# 0.05s
@time count_lines_async(path, 128000)
# 45 ms

@time count_lines_async(path, 2^15)
