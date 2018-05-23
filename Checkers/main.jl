include("game.jl")
include("mcts.jl")

examples = Dict(
    :cool => (Int64[0 0 0 -1; 0 -1 -1 0; 0 0 0 0; 0 -1 0 -1; 1 1 0 0; 0 0 0 -1; -1 -1 -1 1; 1 1 1 1], Int64[7, 9], 0),
    :c2 => (Int64[-1 -1 -1 -1; -1 1 1 1; 1 0 0 0; 0 0 -1 -1; 1 0 1 0; 0 0 0 0; 0 1 1 0; 1 0 0 0], Int64[9, 7], 1),
    :default => (default_state, Int64[12, 12], 0),
)

function testConvergence(;min=5, max=30, id=:cool, loop=1, mcts=100, c=1.414)
    startState = Game()
    startState.states, startState.men, startState.pID = deepcopy(examples[id])
    for i in 1:loop
        g = makecopy(startState)
        t = Tree(false, uct=c)
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
    t = Tree(false)
    while canMove(g)
        MCTS(mcts, t, g)
        selectBestMove(g, t)
        sh(g)
    end
    return g, t
end

function twoAgents(;mcts=100, c=(0.5, 1.414))
    g = Game()
    g.states, g.men, g.pID = deepcopy(examples[:c2])
    agents = (Tree(false, uct=c[1]), Tree(false, uct=c[2]))
    sh(g)
    while canMove(g)
        println("Player $(g.pID == 0 ? "WHITE" : "BLACK")…")
        MCTS(mcts, agents[g.pID+1], g)
        # println(getValidMoves(g))
        selectBestMove(g, agents[g.pID+1])
        sh(g)
    end
    return g
end

@enum Player HUMAN=0

function playHumanVsMCTS(;mcts=130)
    print("Human name: ")
    name = readline()
    g = Game()
    agent = Tree(false, uct=0.5)
    players = (HUMAN, agent)
    while canMove(g)
        println("Player $(g.pID == 0 ? name : "MonteCarlo")")
        sh(g)
        MCTS(mcts, players[g.pID+1], g)
        selectBestMove(g, players[g.pID+1])
    end
    sh(g)
    return g
end

function selectBestMove(g::Game, ::Player)
    move(g, parseUserAction())
end

function MCTS(::Int64, ::Player, ::Game) end

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
