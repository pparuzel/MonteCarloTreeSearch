mutable struct Node
    wins::Float64
    sims::Int64
    parent::Union{Node, Void}
    children::Array{Node, 1}
    action::Tuple{Int64,Int64,Vararg{Int64,N} where N}

    Node(parent::Union{Node, Void}, action::Tuple{Int64,Int64,Vararg{Int64,N} where N}) = new(0, 1, parent, Node[], action)

    Node(::Bool) = new(0, 1, nothing, Node[], (0, 0))
end

__LOGARITHM__ = [log(i) for i in 1:10000]

function ln(i::Int64)
    if i <= 10000
        return __LOGARITHM__[i]
    else
        return log(i)
    end
end

mutable struct Tree
    root::Node
    UCT::Function

    function Tree(; uct=1.414)
        this = new(Node(true))
        # TODO: Possible optimization!
        UCT_func(ptr) = ptr.wins / ptr.sims + uct * sqrt(ln(ptr.parent.sims) / ptr.sims)
        this.UCT = UCT_func
        return this
    end
end

function argmax(func, arr)
    v, best_i = findmax(func(ch) for ch in arr)
    return best_i
end

function MCTS(itersNum::Int64, tree::Tree, game::Game, initMoves::Array{Tuple{Int64,Int64,Vararg{Int64,N} where N},1})
    for mv in initMoves
        push!(tree.root.children, Node(tree.root, mv))
    end
    (length(initMoves) == 1) && (#=sleep(0.8);=# return nothing)
    # Start of MCTS loop
    for i in 1:itersNum
        ptr = tree.root
        g = makecopy(game)
    # NOTE: Selection
        while !isempty(ptr.children)
            best_i = argmax(tree.UCT, ptr.children)
            ptr = ptr.children[best_i]
            v = getValidMoves(g)
            @assert ptr.action in v "This move is illegal"
            move(g, ptr.action)
        end
    # NOTE: Expansion
        valid = getValidMoves(g)
        if canMove(g)
            ptr.children = Node[Node(ptr, action) for action in valid]
            actionNode = rand(ptr.children)
            ptr = actionNode
            move(g, actionNode.action)
            valid = getValidMoves(g)
        end
        currentPlayer = g.states[g.lastAction[2]] > 0 ? 1 : -1
    # NOTE: Simulation
        while canMove(g)
            move(g, rand(valid))
            valid = getValidMoves(g)
        end
    # NOTE: Backpropagation
        if g.winner == 0 # game ended with a tie
            while ptr != tree.root
                ptr.sims += 1
                ptr.wins += 0.5
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
    return nothing
end

function selectBestMove(g::Game, t::Tree)
    best_i = indmax(ch.sims for ch in t.root.children)
    t.root = t.root.children[best_i]
    t.root.parent = nothing
    empty!(t.root.children)
    v = getValidMoves(g)
    @assert (t.root.action in v) "This move is illegal"
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
