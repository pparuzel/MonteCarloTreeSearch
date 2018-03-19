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
