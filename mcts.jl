include("game.jl")

function main()
    b = Board(3, row=3)
    b.show()

    while b.active
        input = parse(Int64, readline())
        put!(b, input)
        b.show()
    end
end

function test()
    b = Board(3, row=3)
end

main()
# test()
