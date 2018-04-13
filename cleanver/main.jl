include("game.jl")
include("ai.jl")

function main()
    game = Game(3)
    legalmove(game, 4)
    sh(game)
end

function ai(t::Tree, g::Game)
    mcts(t, g, seconds=1)
    # selectOption()
    println("selectOption()")
    (t, g)
end
