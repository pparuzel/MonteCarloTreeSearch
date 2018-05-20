include("game.jl")
include("mcts.jl")

g = Game()
t = Tree(g)
while canMove(g)
    MCTS(3000, t, g)
    selectBestMove(g, t)
    sh(g)
end
