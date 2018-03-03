function selection(ptr)
    # Select the most promising node
    # until you find a leaf
    # starting from some given node

    while !isempty(ptr.children)
        # println("Okay, we have $([p for p in ptr.children]). Which one is the best?")
        ptr = ptr.children[indmax(UCT.(ptr.children))]
    end
    return ptr
end

function expansion()
    # Unless leaf node ends the game
    # expand it by number of possible moves
    # and choose one of the added nodes randomly

    
end

function simulation()
    # Perform a simulation starting from
    # the randomly chosen node and return
    # who won that playout
end

function backpropagation(gameptr)
    # Update information to the parent nodes
    # up to the given node increasing visits counter
    # and increasing wins for winner's nodes
end

if !isdefined(:Game)
    abstract type Game end
end

mutable struct Node
    # Tree node
    # Stores information about wins and
    # simulations played after this game state

    wins::Int64
    sims::Int64
    children::Array{Node, 1}
    parent::Union{Void, Node}

    function init!(this::Node)
        this.wins = 0
        this.sims = 0
        this.children = Node[]
    end

    function Node(::Void)
        this = new()
        init!(this)
        this.parent = nothing
        return this
    end

    function Node(parent::Node)
        this = new()
        init!(this)
        this.parent = parent
        return this
    end
end

Base.show(io::IO, x::Node) = print(io, "Node($(x.wins)/$(x.sims), $(length(x.children))$(x.parent == nothing ? ", root" : ""))")

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

mutable struct AI
    # Artificial Intelligence class

    mark::Int8
    tree::Tree
    gameptr::Node
    # Is it needed?
    game::Union{Game, Void}
    UCT::Function
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
            # TODO: Implement NOT completely random choices
            current = gameptr
            for i in 1:10
                selection(current)
                expansion()
                simulation()
                backpropagation(gameptr)
            end
            return rand(1:9)
        end

        return this
    end
end
