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
    # Template board TRANSPOSED (!)
    board = Int8[ 1  1  0;
                 -1  1  0;
                 -1 -1  1]'
    b = Board(board, row=3)
    b.show()
    println("Winner: ", check(b))
end

# main()
test()
