#=

    Artificial Intelligence structures

=#

if !isdefined(:Game)
    abstract type Game end
end

if !isdefined(:Node)

mutable struct Node
    # Tree node
    # Stores information about wins and
    # simulations played after this game state

    # is it needed?
    mark::Int8
    #
    wins::Int64
    sims::Int64
    children::Array{Node, 1}
    parent::Union{Void, Node}

    function init!(this::Node)
        this.wins = 0
        this.sims = 0
        this.children = Node[]
    end

    function Node(mark::Int8)
        this = new()
        init!(this)
        this.mark = mark
        # this.parent = nothing
        return this
    end

    function Node(parent::Node)
        this = new()
        init!(this)
        this.mark = -parent.mark
        this.parent = parent
        return this
    end
end

end # IF NOT DEFINED

mutable struct Tree
    # Game tree

    head::Node
    add::Function

    function Tree(dim::Int64)
        this = new()

        tmp::Int8 = 1
        this.head = Node(tmp)

        for i in 1:dim
            push!(this.head.children, Node(this.head))
        end

        this.add = function(parent::Node)
            push!(parent.children, Node(parent))
        end

        return this
    end
end

mutable struct AI
    # Artificial Intelligence class

    mark::Int8
    tree::Tree
    γ::Float64
    # Is it needed?
    game::Game
    UCT::Function
    choice::Function

    function AI(dim::Int64; γ=sqrt(2), plays::Game=nothing)
        this = new()
        # game mark
        this.mark = isX ? 1 : -1
        # exploration rate
        this.γ = γ
        # starting tree
        this.tree = Tree(dim)

        this.game = plays
        this.UCT = function(wins, sims, parentsims)
            # Upper Confidence Bound
            # applied to Trees formula

            if parentsims == 0
                return 0.0
            end
            if sims == 0
                return wins * γ * sqrt(log(parentsims))
            end

            return wins / sims * γ * sqrt(log(parentsims) / sims)
        end

        this.choice = function()
            # TODO: Implement NOT completely random choices
            return rand(1:9)
        end

        return this
    end
end
