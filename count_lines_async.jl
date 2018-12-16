PATH = "worldcitiespop.txt"

function count_lines(buf, from = 1, to = length(buf))
    eol = Int('\n')
    nb = 0
    the_size = length(buf)
    for i = from:to
        @inbounds if buf[i] == eol
            nb += 1
        end
    end
    return nb
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
@time count_lines_async(path, Int(round(the_size/4)))
@time count_lines_async(path, 128000)
