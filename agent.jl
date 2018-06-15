include("config.jl")

mutable struct Node
    key::Int
    wins::Float64
    sims::Int
    winsAMAF::Float64
    simsAMAF::Int
    parent::Union{Node, Void}
    children::Array{Node, 1}

    Node(key::Int, parent::Union{Node, Void}) = new(key, 0, 0, 0, 0, parent, [])
end

mutable struct Agent
    root::Node
    ptr::Node
    exploration_rate::Float64
    rave_squared::Float64

    function Agent(width::Int; explrate=1, rave=0.1)
        root = Node(-1, nothing)
        for i in 1:width
            push!(root.children, Node(i, root))
        end
        return new(root, root, explrate, rave^2)
    end
end

function restart(t::Agent)
    t.ptr = t.root
end

function uctIndex(parent, rave_squared, explrate)
    uctmax = 0
    uctmax_i = 0
    θ = explrate * sqrt(log(parent.sims + 1))
    for i in 1:length(parent.children)
        ch = parent.children[i]
        n = ch.sims
        ñ = ch.simsAMAF
        if ñ == 0
            β = 0
        else
            β = ñ / (n + ñ + 4 * rave_squared * n * ñ)
        end
        uctval = (1 - β) * ch.wins / (n + 1) + (β * ch.winsAMAF / (ñ + 1)) + θ * sqrt(1 / (n + 1))
        if uctmax < uctval
            uctmax = uctval
            uctmax_i = i
        end
    end
    return (uctmax_i == 0 ? rand(1:length(parent.children)) : uctmax_i)
end

function mcts(agent::Agent, game::Game; maxIters=1000)
    ptr = agent.ptr
    flatsize = game.size ^ 2
    # seconds *= 1e9
    # t0 = time_ns()
    # while time_ns() - t0 < seconds
    for i in 1:maxIters
        g = makecopy(game)
        movekeys = (Int[], Int[])
        INDEX = 1
        # NOTE: selection
        while !isempty(ptr.children)
            best_i = uctIndex(ptr, agent.rave_squared, agent.exploration_rate)
            ptr = ptr.children[best_i]
            legalmove(g, ptr.key, with_check=false)
            push!(movekeys[INDEX], ptr.key)
            INDEX = (INDEX % 2) + 1
        end
        # NOTE: expansion
        """ check if game ended here """
        winner = check(g)
        if g.isrunning
            for node in ptr.parent.children
                (node.key == ptr.key) && continue
                push!(ptr.children, Node(node.key, ptr))
            end
            shuffled = shuffle(ptr.children)
            ptr = shuffled[1]
            winner = legalmove(g, ptr.key)
            push!(movekeys[INDEX], ptr.key)
            INDEX = (INDEX % 2) + 1
        end
        # NOTE: simulation
        shff_i = 2
        while g.isrunning
            winner = legalmove(g, shuffled[shff_i].key)
            push!(movekeys[INDEX], ptr.key)
            INDEX = (INDEX % 2) + 1
            shff_i += 1
        end
        # NOTE: backpropagation
        increment = winner == 0 ? coinflip() : 1
        while ptr != agent.ptr
            ptr.sims += 1
            ptr.wins += increment
            for p in ptr.parent.children
                (p == ptr) && continue
                if p.key in movekeys[INDEX]
                    p.simsAMAF += 1
                    p.winsAMAF += increment
                end
            end
            ptr = ptr.parent
            # INDEX = (INDEX % 2) + 1
            INDEX = 3 - INDEX
            # TODO: 3 - INDEX

            # increment = (increment + 1) % 2
            increment = 1 - increment
            # TODO:  := inc xor 0x01
        end
        ptr.sims += 1
        ptr.wins += increment
    end
end

function selectBestOption(t::Agent, g::Game; opponent=nothing)
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

# Node output

function __show_node__(io::IO, node::Node, level=0)
    println(io, "-" ^ 2level, node)
    for n in node.children
        __show_node__(io, n, level + 1)
    end
end

function Base.show(io::IO, t::Agent)
    print(io, t.root, "…")
end

function depth(node::Node, _depth::Int64, level=0)
    (_depth == level) && println("-" ^ 2level, node)
    for n in node.children
        depth(n, _depth, level + 1)
    end
    nothing
end

configure()
