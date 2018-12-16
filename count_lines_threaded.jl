
using Mmap

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

function count_lines_mmap_by_chunk(path, chunk_size = 64000)
    fh = open(path)
    the_size = stat(fh).size
    mm = Mmap.mmap(fh, Matrix{UInt8}, (the_size,1))

    nb_chunks = Int(ceil(the_size / chunk_size))
    nb_lines = zeros(nb_chunks)
    for i = 1:nb_chunks
        nb_lines[i] = count_lines(mm, chunk_size * (i - 1) + 1, chunk_size)
    end

    close(fh)
    return Int(sum(nb_lines))
end

Threads.nthreads()
Threads.threadid()

path = "worldcitiespop.txt"

count_lines_mmap_by_chunk(path)

@time count_lines_mmap_by_chunk(path)
# 0.055010 seconds
@time count_lines_mmap_by_chunk(path, 32)
# 0.090712 seconds
@time count_lines_mmap_by_chunk(path, 32000)
#  0.041753 seconds

function count_lines_mmap_threaded(path, chunk_size = 64000)
    fh = open(path)
    the_size = stat(fh).size
    mm = Mmap.mmap(fh, Matrix{UInt8}, (the_size,1))

    nb_chunks = Int(ceil(the_size / chunk_size))
    nb_lines = zeros(nb_chunks)
    Threads.@threads for i = 1:nb_chunks
        nb_lines[i] = count_lines(mm, chunk_size * (i - 1) + 1, chunk_size)
    end

    close(fh)
    return Int(sum(nb_lines))
end

@time count_lines_mmap_by_chunk(path, 1000)
# 0.025680 seconds
@time count_lines_mmap_by_chunk(path, 10000)
# 0.029258 seconds
@time count_lines_mmap_by_chunk(path, 100000)
#  0.025177
