path = "worldcitiespop.txt"
fh = open(path)
buffer = Array{UInt8}(undef, Int(round(stat(fh).size / 4)))
readbytes!(fh, buffer)
close(fh)

function count_lines_buffer(buf)
    eol = Int('\n')
    nb = 0
    the_size = length(buf)
    for i = 1:the_size
        @inbounds if buf[i] == eol
            nb += 1
        end
    end
    return nb
end

@time count_lines_buffer(buffer)
