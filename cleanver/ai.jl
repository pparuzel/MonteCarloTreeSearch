mutable struct Node
    wins::Int
    sims::Int
    parent::Union{Node, Void}
    children::Array{Node, 1}

    Node(parent::Union{Node, Void}) = new(0, 0, parent, [])
end

mutable struct Tree
    root::Node
    ptr::Node

    function Tree(width::Int)
        root = Node(nothing)
        for i in 1:width
            push!(root.children, Node(root))
        end
        return new(root, root)
    end
end

function uctIndex(parent; η = 2)
    uctmax = 0
    uctmax_i = 1
    θ = sqrt(η * log(parent.sims + 1))
    for i in 1:length(parent.children)
        ch = parent.children[i]
        uctval = ch.wins / (ch.sims + 1) + θ * sqrt(1 / (ch.sims + 1))
        if uctmax < uctval
            uctmax = uctval
            uctmax_i = i
        end
    end
    return uctmax_i
end

coinflip() = Int(rand(Bool))

UCT(ch) = ch.wins / (ch.sims + 1) + sqrt(log(ch.parent.sims + 1) / (ch.sims + 1))

function mcts(tree::Tree, game::Game; seconds=-1)
    ptr = tree.ptr
    g = makecopy(game)
    seconds *= 1e9
    t0 = time_ns()
    while time_ns() - t0 < seconds
        g = makecopy(game)
        # NOTE: selection
        while !isempty(ptr.children)
            best_i = uctIndex(ptr)
            ptr = ptr.children[best_i]
            nodemove(g, best_i)
        end
        # NOTE: expansion
        """ check if game ended here """
        winner = check(g)
        if g.isrunning
            newlen = length(ptr.parent.children) - 1
            ptr.children = Node[Node(ptr) for i in 1:newlen]
            move_i = rand(1:newlen)
            ptr = ptr.children[move_i]
            winner = nodemove(g, move_i)
        end
        # NOTE: simulation
        gsize = g.size ^ 2
        while g.isrunning
            winner = nodemove(g, rand(1:gsize - g.turn))
        end
        # NOTE: backpropagation
        increment = winner == 0 ? coinflip() : 1
        while ptr != tree.ptr
            ptr.sims += 1
            ptr.wins += increment
            ptr = ptr.parent
            increment = (increment + 1) % 2
        end
        ptr.sims += 1
        ptr.wins += increment
    end
end

# Node output

Base.show(io::IO, x::Node) = print(io, "Node($(x.wins)/$(x.sims), $(length(x.children))$(x.parent == nothing ? ", root" : ""))")

function __show_node__(io::IO, node::Node, level=0)
    println(io, "-" ^ 2level, node)
    for n in node.children
        __show_node__(io, n, level + 1)
    end
end

function Base.show(io::IO, t::Tree)
    __show_node__(io, t.root)
end

function depth(node::Node, _depth::Int64, level=0)
    (_depth == level) && println("-" ^ 2level, node)
    for n in node.children
        depth(n, _depth, level + 1)
    end
    nothing
end
