include("game.jl")
include("ai.jl")
include("player.jl")

function pvp()
    tictactoe = Board(3, row=3)
    tictactoe.show()
    player = Player()
    tictactoe.players = (player, player)

    while tictactoe.isrunning
        tictactoe.make_turn()
        tictactoe.show()
    end
end

function test()
    # Template board
    intboard = Int8[ 1 -1  0;
                    -1  1  0;
                     1 -1 -1]
    board = Board(intboard, row=3)
    board.show()
    println("Winner: ", check(board))
end

function pve()
    tictactoe = Board(3, row=3)
    tictactoe.show()
    ai = AI(3, plays=tictactoe)
    player = Player()
    set_players!(tictactoe, (ai, player))

    while tictactoe.isrunning
        tictactoe.make_turn()
        tictactoe.show()
    end

    println("AI.MARK ", ai.mark)
end

function test_selection()
    ai = AI(3)
    ptr = ai.tree.root
    # tree with root and two children
    ptr.wins = 2; ptr.sims = 2;
    ptr.children = Node[Node(ptr), let; tmp = Node(ptr);
    tmp.wins = 2; tmp.sims = 2; tmp; end]
    #
    ptr = selection(ai.gameptr);
    print(ptr)
end

# pvp()
# pve()
# test_selection()
