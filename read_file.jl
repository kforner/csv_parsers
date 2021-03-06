
PATH = "worldcitiespop.txt"

function read_file_in_memory(path)
    fh = open(path)
    s = read(fh, String)
    close(fh)
end


function read_bytes_in_memory(path)
    GC.enable(false)
    fh = open(path)
    size = stat(fh).size
    buffer = Array{UInt8}(undef, size)
    readbytes!(fh, buffer)
    close(fh)
end

read_file_in_memory(PATH)

@time read_file_in_memory(PATH)

@time read_bytes_in_memory(PATH)




using Profile

@profile read_bytes_in_memory(PATH)

Profile.print()



using Mmap

fh = open(PATH)
the_size = stat(fh).size
mm = Mmap.mmap(fh, Matrix{UInt8}, (the_size,1))
Mmap.sync!(mm)

function read_bytes_using_mmap(path)
    fh = open(path)
    the_size = stat(fh).size
    mm = Mmap.mmap(fh, Matrix{UInt8}, (the_size,1))
    Mmap.sync!(mm)
    close(fh)
end

@time read_bytes_using_mmap(PATH)

function count_lines(path)
    fh = open(path)
    the_size = stat(fh).size
    buffer = Array{UInt8}(undef, the_size)
    readbytes!(fh, buffer)
    nb = 0
    eol = Int('\n')
    for i = 1:the_size
        @inbounds if buffer[i] == eol
            nb += 1
        end
    end
    return nb
end

function count_lines_mmap(path)
    fh = open(path)
    the_size = stat(fh).size
    mm = Mmap.mmap(fh, Matrix{UInt8}, (the_size,1))

    nb = 0
    eol = Int('\n')
    for i = 1:the_size
        if mm[i] == eol
            nb += 1
        end
    end
    #Mmap.sync!(mm)
    close(fh)
    return nb
end

count_lines_mmap(PATH)

@time count_lines_mmap(PATH)
@time count_lines(PATH)

using CSV
using DataFrames

@time df = CSV.File(PATH)

@time df = CSV.File(PATH) |> DataFrame
@time df = CSV.read(PATH)
