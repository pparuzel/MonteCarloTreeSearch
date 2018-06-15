include("game.jl")
include("agent.jl")

# function twoAgents(;iter=100, c=(1.414, 1.414))
#     game = Game()
#     agents = (Tree(uct=c[1]), Tree(uct=c[2]))
#     while true
#         valid = getValidMoves(game)
#         canMove(game) || break
#         MCTS(iter, agents[game.pID+1], game, valid)
#         selectBestMove(game, agents[game.pID+1])
#     end
#     return game.winner
# end
#
# SIZE = 100
# agents05n1414 = Dict(0 => 0, -1 => 0, 1 => 0)
# progress_bar_width = 45
#
# for i in 1:SIZE
#     # Progress bar
#     proc = div(100i, SIZE)
#     amt = div(progress_bar_width*i, SIZE)
#     dashes = "-" ^ amt
#     empty = "_" ^ (progress_bar_width - amt)
#     print("\r|$(dashes)$(empty)| $(proc)%\t")
#     # Simulation
#     agents05n1414[twoAgents(iter=20, c=(3.0, 1.414))] += 1
# end
# println()
#
# # agents05n1414 = Dict(0=>58,-1=>39,1=>3)
#
# @show agents05n1414


function demo(;size=3, inrow=3, time=(1, 1), one=nothing, two=nothing)
    g = Game(size, row=inrow)
    one != nothing ? (ai1 = one) : (ai1 = Agent(size^2))
    two != nothing ? (ai2 = two) : (ai2 = Agent(size^2))
    sh(g)
    while g.isrunning
        mcts(ai1, g, seconds=time[1])
        selectBestOption(ai1, g, opponent=ai2)
        sh(g)
        if !g.isrunning; break; end;
        mcts(ai2, g, seconds=time[2])
        selectBestOption(ai2, g, opponent=ai1)
        sh(g)
    end

    return Dict(:one => ai1, :two => ai2, :game => g)
end

configure(ties=:half)

function gatherData(;iters=10000, expl=0.5, rave=100)
    g = Game(5, row=4)
    ai1 = Agent(25, explrate=expl, rave=rave)
    ai2 = Agent(25, explrate=expl, rave=rave)
    # sh(g)
    while g.isrunning
        mcts(ai1, g, maxIters=iters)
        selectBestOption(ai1, g, opponent=ai2)
        # sh(g)
        if !g.isrunning; break; end;
        mcts(ai2, g, maxIters=iters)
        selectBestOption(ai2, g, opponent=ai1)
        # sh(g)
    end
    return check(g)
end

function gatherFinal()
    iters=10000
    g = Game(5, row=4)
    ai1 = Agent(25, explrate=0.5, rave=100)
    ai2 = Agent(25, explrate=0.5, rave=0.5)
    # sh(g)
    while g.isrunning
        mcts(ai1, g, maxIters=iters)
        selectBestOption(ai1, g, opponent=ai2)
        # sh(g)
        if !g.isrunning; break; end;
        mcts(ai2, g, maxIters=iters)
        selectBestOption(ai2, g, opponent=ai1)
        # sh(g)
    end
    return check(g)
end
