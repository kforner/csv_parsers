c = Channel(2)
put!(c, 1)
close(c)

for stuff in c
    println("stuff=", stuff)
end
