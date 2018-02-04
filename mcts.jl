include("game.jl")

function selection()
    # Select the most promising node
    # until you find a leaf
    # starting from some given node
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

function backpropagation()
    # Update information to the parent nodes
    # up to the given node increasing visits counter
    # and increasing wins for winner's nodes
end

type Node
    # Tree node
    # Stores information about wins and
    # simulations played after this game state

    mark::Int8
    wins::Int64
    sims::Int64
    children::Array{Node, 1}
    parent::Node

    function init!(this::Node)
        this.wins = 0
        this.sims = 0
        this.children = Node[]
    end

    function Node(mark::Int8)
        this = new()
        init!(this)
        this.mark = mark
        this.parent = nothing
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

type Tree
    # Game tree

    head::Node
    add::Function

    function Tree()
        this = new()

        this.add = function(parent::Node)
            push!(parent.children, Node())
        end

        return this
    end
end

type AI
    # Artificial Intelligence for TicTacToe

    mark::Int8
    tree::Tree
    γ::Float64
    UCT::Function

    function AI(mark::Int8, dim::Int64; γ=sqrt(2))
        this = new()
        # game mark
        this.mark = mark
        # exploration rate
        this.γ = γ
        # starting tree
        this.tree = Tree(dim)

        this.UCT = function(wins, sims, parentsims)
            # Upper Confidence Bound
            # applied to Trees formula

            return wins / sims * sqrt(γ * log(parentsims) / sims)
        end

        return this
    end
end

function main()
    b = Board(3, row=3)
    b.show()

    while b.active
        input = parse(Int64, readline())
        put!(b, input)
        b.show()
    end
end

function test()
    # Template board TRANSPOSED (!)
    board = Int8[ 1  1  0;
                 -1  1  0;
                 -1 -1  1]'
    b = Board(board, row=3)
    b.show()
    println("Winner: ", check(b))
end

function test1()
    b = Board(3, row=3)
    b.show()

end

# main()
# test()
test1()
