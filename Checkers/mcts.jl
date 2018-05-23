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
    UCT::Function

    # function Tree(game::Game)
    #     root = Node(true)
    #     root.sims = 1
    #     validMoves = getValidMoves(game)
    #     for move in validMoves
    #         push!(root.children, Node(root, move))
    #     end
    #     return new(root)
    # end

    function Tree(::Bool; uct=1.414)
        this = new(Node(true))
        # TODO: Possible optimization!
        UCT_func(ptr) = ptr.wins / ptr.sims + uct * sqrt(log(ptr.parent.sims) / ptr.sims)
        this.UCT = UCT_func
        return this
    end
end

function argmax(func, arr)
    v, best_i = findmax(func(ch) for ch in arr)
    return best_i
end

function MCTS(itersNum::Int64, tree::Tree, game::Game)
    if game.hopMove
        validMoves = getValidMovesAfterHop(game, game.lastAction[2])
        if length(validMoves) == 0
            validMoves = getValidMoves(game)
        end
    else
        validMoves = getValidMoves(game)
    end
    for mv in validMoves
        push!(tree.root.children, Node(tree.root, mv))
    end
    for i in 1:itersNum
        ptr = tree.root
        g = makecopy(game)
    # NOTE: Selection
        while !isempty(ptr.children)
            best_i = argmax(tree.UCT, ptr.children)
            ptr = ptr.children[best_i]
            justMove(g, ptr.action)
        end
        updatePlayerID(g) # necessary TEST IT!
    # NOTE: Expansion
        if g.hopMove
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
        while canMove(g)
            valid = move(g, rand(valid))
        end
    # NOTE: Backpropagation
        if g.winner == 0
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
end

function selectBestMove(g::Game, t::Tree)
    best_i = indmax(ch.sims for ch in t.root.children)
    t.root = t.root.children[best_i]
    t.root.parent = nothing
    empty!(t.root.children)
    println("$(g.pID) played", t.root.action, " and ", g.lastAction)
    move(g, t.root.action)

    t.root.action
end

# deprecated
function informOpponent(t::Tree, lastAction::Tuple{Int64,Int64,Vararg{Int64,N} where N})
    ind = findfirst(x->x.action==lastAction, t.root.children)
    @assert ind != 0 "last action $(lastAction) not found"
    t.root = t.root.children[ind]
    t.root.parent = nothing
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
