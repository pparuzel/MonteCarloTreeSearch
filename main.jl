include("game.jl")
include("ai.jl")

function main()
    game = Game(3)
    legalmove(game, 4)
    sh(game)
end

function selectBestOption(t, g; opponent=nothing)
    # assign new t.ptr
    bestsims = 0
    best_i = 0
    for i in 1:length(t.ptr.children)
        child = t.ptr.children[i]
        if bestsims < child.sims
            bestsims = child.sims
            best_i = i
        end
    end
    t.ptr = t.ptr.children[best_i]
    if opponent != nothing
        opponent.ptr = opponent.ptr.children[best_i]
    end
    nodemove(g, best_i)
end

function ai(t::Tree, g::Game; seconds=1)
    mcts(t, g, seconds=seconds)
    selectBestOption(t, g)
    (t, g)
end

function demo(;size=3, inrow=3, time=(1, 1), one=nothing, two=nothing)
    g = Game(size, row=inrow)
    one != nothing ? (ai1 = one) : (ai1 = Tree(size^2))
    two != nothing ? (ai2 = two) : (ai2 = Tree(size^2))
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
