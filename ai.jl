include("node.jl")

using Base

function select_best(gameptr::Node, board::Game)
    pos = indmax(broadcast(n -> n.sims, gameptr.children))
    gameptr = gameptr.children[pos]
    mv = 0
    for i in 1:board.xdim
        for j in 1:board.xdim
            if board.states[j, i] == 0
                mv += 1
                if mv == pos
                    return (i - 1) * board.xdim + j
                end
            end
        end
    end
end

function selection(ptr::Node, game::Game)::Node
    # Select the most promising node
    # until you find a leaf
    # starting from some given node

    while !isempty(ptr.children)
        # println("Okay, we have $([p for p in ptr.children]). Which one is the best?")
        best_i = indmax(UCT.(ptr.children))
        ptr = ptr.children[best_i]
        nodemove!(game, best_i)
    end
    return ptr
end

function expansion(ptr::Node, game::Game)
    # Unless leaf node ends the game
    # expand it by number of possible moves
    # and choose one of the added nodes randomly

    """ check if game ended here """
    winner = check(game)
    game.isrunning || return ptr, winner

    newlen = length(ptr.parent.children) - 1
    ptr.children = Node[Node(ptr) for i in 1:newlen]
    move_i = rand(1:newlen)
    ptr = ptr.children[move_i]
    nodemove!(game, move_i)
    # no winner yet === 0
    return ptr, Int8(0)
end

function simulation(game::Game, result::Int8)::Int8
    # Perform a simulation starting from
    # the randomly chosen node and return
    # who won that playout

    while game.isrunning
        result = nodemove!(game, rand(1:(9 - game.turn)))
    end

    return result
end

function backpropagation(ptr::Node, gameptr, result::Int8)
    # Update information to the parent nodes
    # up to the given node increasing visits counter
    # and increasing wins for winner's nodes

    increment = 1
    result = abs(result)

    while ptr != gameptr
        ptr.sims += 1
        # ptr.wins += (game.turn % 2 == 1 ? 1 : -1) * result
        ptr.wins += increment * result
        ptr = ptr.parent
        increment = (increment + 1) % 2
    end
    nothing
end

if !isdefined(:Game)
    abstract type Game end
end

mutable struct Tree
    # Game tree

    root::Node
    add::Function

    function Tree(dim::Int64)
        this = new()
        this.root = Node(nothing)

        for i in 1:dim
            push!(this.root.children, Node(this.root))
        end

        this.add = function(parent::Node)
            push!(parent.children, Node(parent))
        end

        return this
    end
end

isroot(ptr)::Bool = ptr.parent == nothing

function __show_node__(io::IO, node::Node, level=0)
    println(io, "-" ^ 2level, node)
    for n in node.children
        __show_node__(io, n, level + 1)
    end
end

function Base.show(io::IO, t::Tree)
    __show_node__(io, t.root)
end

function UCT(ptr::Node; γ=sqrt(2))::Float64
    # Upper Confidence Bound
    # applied to Trees formula
    wins = ptr.wins
    sims = ptr.sims
    if isroot(ptr)
        return 0.0
    else
        parentsims = ptr.parent.sims
    end
    if parentsims == 0
        return 0.0
    end
    if sims == 0
        return γ * sqrt(log(parentsims))
    end
    return wins / sims + γ * sqrt(log(parentsims) / sims)
end

function indexToNode(game::Game, last_move::Int64)
    res = 0
    for i in 1:length(game.states)
        if game.states[i] == 0
            res += 1
            if i == last_move
                break
            end
        end
    end
    return res
end

mutable struct AI
    # Artificial Intelligence class

    mark::Int8
    tree::Tree
    gameptr::Node
    # Is it needed?
    game::Union{Game, Void}
    choice::Function

    function AI(dim::Int64; plays=nothing)
        this = new()

        """ CHECK IF NEEDED? """
        # # game mark initialized by tictactoe
        # this.mark = 0

        # starting tree
        this.tree = Tree(dim)
        # game indicator
        this.gameptr = this.tree.root

        this.game = plays

        this.choice = function()
            current = this.gameptr
            gamecopy = deepcopy(this.game)
            for i in 1:1
                current = selection(current, gamecopy)
                res = expansion(current, gamecopy)
                res = simulation(gamecopy, res)
                backpropagation(current, this.gameptr, res)
            end
            return rand(1:9)
        end
#=
        this.choice = function()
            if this.game.last_move != -1
                child_id = indexToNode(this.game, this.game.last_move)
                this.gameptr = this.gameptr.children[child_id]
            end
            # TODO: Implement NOT completely random choices
            current = this.gameptr
            gamecopy = deepcopy(this.game)
            for i in 1:10
                current = selection(current, gamecopy)
                res = expansion(current, gamecopy)
                res = simulation(gamecopy, res)
                backpropagation(current, this.gameptr, res)
            end
            # end of AI tree development
            return select_best(this.gameptr, this.game)
            # return rand(1:9)
        end
=#

        return this
    end
end

Base.show(io::IO, ::AI) = print("AI class")
