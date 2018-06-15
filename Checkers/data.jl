include("game.jl")
include("mcts.jl")

function twoAgents(;iter=100, c=0.5)
    game = Game()
    agents = (Tree(uct=c), Tree(uct=1.414))
    while true
        valid = getValidMoves(game)
        canMove(game) || break
        # println("Player $(game.pID == 0 ? "WHITE" : "BLACK")…")t
        MCTS(iter, agents[game.pID+1], game, valid)
        selectBestMove(game, agents[game.pID+1])
        # sh(game)
    end
    if game.winner == 0
        return 0
    else
        return game.winner
    end
end

dict = Dict(0 => 0, -1 => 0, 1 => 0)

function getDict()
    global dict
    dict = Dict(0 => 0, -1 => 0, 1 => 0)
end

function battle(it=100; mc=100, c=0.5)
    global dict
    for i in 1:it
        dict[twoAgents(iter=mc, c=c)] += 1
        print("\r$(i)%    ")
    end
    return dict
end
