include("game.jl")
include("ai.jl")

function main()
    game = Game(3)
    legalmove(game, 4)
    sh(game)
end

function ndmv(g::Game, pos::Int; debug=false)
    # DEBUG
    if pos > (g.size^2 - g.turn)
        throw("illegal nodemove: $(pos). position is unavailable")
    end
    for i in 1:length(g.states)
        mv = 0
        for i in 1:length(g.states)
            if g.states[i] == 0
                mv += 1
                (mv == pos) && (return i)
            end
        end
    end
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

function ai(t::Tree, g::Game)
    mcts(t, g, seconds=1)
    selectBestOption(t, g)
    (t, g)
end

function demo(;size=3, inrow=3, time=(1, 1))
    g = Game(size, row=inrow)
    ai1 = Tree(size^2)
    ai2 = Tree(size^2)
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

function debug()
    # g = Game(Int8[-1 0 0 0; 0 1 -1 1; 0 1 0 0; 1 -1 0 0], 7, 4, 3)
    g = Game(Int8[-1 -1 1 0; 0 1 -1 1; 0 1 0 0; 1 -1 0 0], 9, 4, 3)
    ai1 = Tree(7)
    ai2 = Tree(7)
    while g.isrunning
        if readline() == "stop"
            return (ai1, ai2)
        end
        mcts(ai1, g, seconds=1)
        selectBestOption(ai1, g, opponent=ai2)
        sh(g)
        if !g.isrunning; break; end;
        if readline() == "stop"
            return (ai1, ai2)
        end
        mcts(ai2, g, seconds=1)
        selectBestOption(ai2, g, opponent=ai1)
        sh(g)
    end
    return (ai1, ai2)
end
