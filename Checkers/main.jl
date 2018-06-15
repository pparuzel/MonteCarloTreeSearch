include("game.jl")
include("mcts.jl")

__examples__ = Dict(
    :cool => (Int64[0 0 0 -1; 0 -1 -1 0; 0 0 0 0; 0 -1 0 -1; 1 1 0 0; 0 0 0 -1; -1 -1 -1 1; 1 1 1 1], Int64[7, 9], 0),
    :atak => (Int64[-1 -1 -1 -1; -1 1 1 1; 1 0 0 0; 0 0 -1 -1; 1 0 1 0; 0 0 0 0; 0 1 1 0; 1 0 0 0], Int64[9, 7], 1),
    :default => (default_state, Int64[12, 12], 0),
)

function setGame(g::Game, id::Symbol)
    g.states = copy(__examples__[id][1])
    g.men[1] = __examples__[id][2][1]
    g.men[2] = __examples__[id][2][2]
    g.pID = __examples__[id][3]
    return nothing
end

function getGame(id::Symbol)
    g = Game()
    g.states = copy(__examples__[id][1])
    g.men[1] = __examples__[id][2][1]
    g.men[2] = __examples__[id][2][2]
    g.pID = __examples__[id][3]
    return g
end

function whose(game::Game)
    println("It's $(game.pID == 0 ? "white" : "black")\'s turn.")
    nothing
end

function board(game::Game)
    sh(game)
    nothing
end

function testConvergence(;min=5, max=30, id=:cool, loop=1, mcts=100, c=1.414)
    startState = Game()
    setGame(startState, id)
    for i in 1:loop
        g = makecopy(startState)
        t = Tree(uct=c)
        pastAction = (0, 0)
        counter = 0
        for i in 1:max
            MCTS(mcts, t, g)
            best_i = indmax(ch.sims for ch in t.root.children)
            action = t.root.children[best_i].action
            if pastAction == action
                counter += 1
                if counter >= min
                    println("Converged after $((i - min + 1)*mcts) iterations to $action")
                    break
                end
            else
                counter = 1
            end
            # println("$i: $action")
            pastAction = action
            if i == max
                println("Does not converge...")
            end
        end
    end
end

function start(;mcts=3000)
    g = Game()
    t = Tree()
    while canMove(g)
        MCTS(mcts, t, g)
        selectBestMove(g, t)
        sh(g)
    end
    return g, t
end

function twoAgents(;iter=100, c=(1.414, 1.414), ex=:default)
    game = Game()
    setGame(game, ex)
    agents = (Tree(uct=c[1]), Tree(uct=c[2]))
    sh(game)
    while true
        valid = getValidMoves(game)
        canMove(game) || break
        println("Player $(game.pID == 0 ? "WHITE" : "BLACK")…")
        MCTS(iter, agents[game.pID+1], game, valid)
        selectBestMove(game, agents[game.pID+1])
        sh(game)
    end
    if game.winner == 0
        println("REMIS")
    else
        println("Wygrał $(game.winner == 1 ? "BIAŁY" : "CZARNY")")
    end
    return game
end

@enum Player HUMAN=0

function playHumanVsMCTS(;iter=130, c=1.414)
    print("Your name: ")
    name = readline()
    g = Game()
    agent = Tree(uct=c)
    players = (HUMAN, agent)
    sh(g)
    while true
        valid = getValidMoves(g) # makes sure which player should play now
        canMove(g) || break
        println("Player $(g.pID == 0 ? name : "MonteCarlo")")
        MCTS(iter, players[g.pID+1], g, valid)
        selectBestMove(g, players[g.pID+1])
        sh(g)
    end
    if g.winner == 0
        println("REMIS")
    else
        println("Wygrał $(g.winner == 1 ? name : "MonteCarlo")")
    end
    return g
end

function selectBestMove(g::Game, ::Player)
    move(g, parseUserAction())
end

function MCTS(::Int64, ::Player, ::Game, ::Array{Tuple{Int64,Int64,Vararg{Int64,N} where N},1}) end

function parseUserAction()
    s = readline()
    if length(s) == 5
        from = 8div(parse(Int, s[2] - 1), 2) + (Int(s[1]) - 96)
        to = 8div(parse(Int, s[5] - 1), 2) + (Int(s[4]) - 96)
        return (from, to)
    end
    from = 8div(parse(Int, s[2] - 1), 2) + (Int(s[1]) - 96)
    to = 8div(parse(Int, s[5] - 1), 2) + (Int(s[4]) - 96)
    attacks = 8div(parse(Int, s[8] - 1), 2) + (Int(s[7]) - 96)
    return (from, to, attacks)
end
