include("game.jl")
include("ai.jl")

function selection()
    # Select the most promising node
    # until you find a leaf
    # starting from some given node
end

function expansion()
    # Unless leaf node ends the game
    # expand it by number of possible moves
    # and choose one of the added nodes randomly
end

function simulation()
    # Perform a simulation starting from
    # the randomly chosen node and return
    # who won that playout
end

function backpropagation()
    # Update information to the parent nodes
    # up to the given node increasing visits counter
    # and increasing wins for winner's nodes
end

function pvp()
    b = Board(3, row=3)
    b.show()

    while b.isrunning
        input = parse(Int64, readline())
        put!(b, input)
        b.show()
    end
end

function test()
    # Template board must be TRANSPOSED
    intboard = Int8[ 1 -1  0;
                    -1  1  0;
                     1 -1 -1]'
    board = Board(intboard, row=3)
    board.show()
    println("Winner: ", check(board))
end

function pve()
    tictactoe = Board(3, row=3)
    tictactoe.show()
    ai = AI(true, 3, plays=tictactoe)
    # TODO:
    '''
        player = Player()
        tictactoe.players = (player, ai)
        while tictactoe.isrunning
            tictactoe.move()
            tictactoe.show()
    '''
    while tictactoe.isrunning
        tictactoe.move(ai.choice())
        tictactoe.show()

        if !tictactoe.isrunning
            break
        end

        player_choice = parse(Int64, readline())
        tictactoe.move(player_choice)
        tictactoe.show()
    end
end

# pvp()
# test()
pve()
