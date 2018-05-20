mutable struct Node
    wins::Float64
    sims::Int64
    parent::Union{Node, Void}
    children::Array{Node, 1}
    action::Tuple{Int64,Int64,Vararg{Int64,N} where N}

    Node(parent::Union{Node, Void}, action::Tuple{Int64,Int64,Vararg{Int64,N} where N}) = new(0, 1, parent, Node[], action)

    Node(::Bool) = new(0, 1, nothing, Node[], (0, 0))
end

mutable struct Tree
    root::Node

    function Tree(game::Game)
        root = Node(nothing, (0, 0))
        root.sims = 1
        validMoves = getValidMoves(game)
        for move in validMoves
            push!(root.children, Node(root, move))
        end
        return new(root)
    end
end

# TODO: Possible optimization!
UCT(ptr; c = 1.414) = ptr.wins / ptr.sims + c * sqrt(log(ptr.parent.sims) / ptr.sims)

argmax(func, arr) = indmax(func(ch) for ch in arr)

function MCTS(itersNum::Int64, tree::Tree, game::Game)
    for i in 1:itersNum
        ptr = tree.root
        g = makecopy(game)
    # NOTE: Selection
        while !isempty(ptr.children)
            best_i = argmax(UCT, ptr.children)
            ptr = ptr.children[best_i]
            justMove(g, ptr.action)
        end
        updatePlayerID(g) # necessary
    # NOTE: Expansion
        if length(ptr.action) > 2
            valid = getValidMovesAfterHop(g, ptr.action[2])
            if length(valid) == 0
                valid = getValidMoves(g)
            end
        else
            valid = getValidMoves(g)
        end
        if canMove(g) && length(valid) > 0
            ptr.children = Node[Node(ptr, action) for action in valid]
            actionNode = rand(ptr.children)
            ptr = actionNode
            valid = move(g, actionNode.action)
        end
        currentPlayer = g.states[g.lastAction[2]] > 0 ? 1 : -1
    # NOTE: Simulation
        while canMove(g) && length(valid) > 0
            valid = move(g, rand(valid))
        end
    # NOTE: Backpropagation
        if g.winner == 0
            while ptr != tree.root
                ptr.sims += 1
                ptr.wins += 0.3
                ptr = ptr.parent
            end
        else
            latest = ptr.action[2]
            while ptr != nothing
                ptr.sims += 1
                if latest != ptr.action[2]
                    currentPlayer = currentPlayer == 1 ? -1 : 1
                end
                if currentPlayer == g.winner
                    ptr.wins += 1
                end
                latest = ptr.action[1]
                ptr = ptr.parent
            end
        end
    end
end

function selectBestMove(g::Game, t::Tree)
    best_i = indmax(ch.sims for ch in t.root.children)
    t.root = t.root.children[best_i]
    t.root.parent = nothing
    move(g, t.root.action)

    t.root.action
end

# node output

function __show_node__(io::IO, node::Node, level=0)
    println(io, "-" ^ 2level, node)
    for n in node.children
        __show_node__(io, n, level + 1)
    end
end

function Base.show(io::IO, t::Tree)
    print(io, t.root, "…")
end

function depth(node::Node, _depth::Int64, level=0)
    (_depth == level) && println("-" ^ 2level, node)
    for n in node.children
        depth(n, _depth, level + 1)
    end
    nothing
end

Base.show(io::IO, x::Node) = print(io, "Node($(x.wins)/$(x.sims) $(length(x.children)), A: $(x.action))")
