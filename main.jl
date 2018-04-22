include("game.jl")
include("agent.jl")

function main()
    game = Game(3)
    legalmove(game, 4)
    sh(game)
end

function ai(t::Agent, g::Game; seconds=1)
    mcts(t, g, seconds=seconds)
    selectBestOption(t, g)
    (t, g)
end

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

nothing
