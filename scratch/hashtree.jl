struct Node
    states::Array{Int8, 2}
    parent::Union{Node, Void}
    children::Array{Node, 1}

    function Node(states::Array{Int8, 2}, parent::Union{Node, Void})
        return new(states, parent, [])
    end
end

statsMap = Dict{Array{Int8, 2}, Tuple{Int64, Int64}}()

struct Tree
    root::Node

    function Tree(width::Int)
        # add = function(parent::Node)
        #     push!(parent.children, Node(parent))
        # end

        this = new(Node(zeros(Int8, (width, width)), nothing), add)

        for i in 1:width^2
            states = zeros(Int8, (width, width))
            states[i] += 1
            push!(this.root.children, Node(states, this.root))
        end

        return this
    end
end

function expandnode(parent::Node)
    # parent.states
end

mutable struct Board
    states::Array{Int8, 2}
    size::Int
    turn::Int
    isrunning::Bool
    row::Int

    function Board(size::Int; row=3)
        this = new()
        this.states = zeros(Int8, (size, size))
        this.size = size
        this.turn = 0
        this.isrunning = true
        this.row = row
        return this
    end

    function Board(states::Array{Int8, 2}; row=3)
        this = new()
        dim = size(states)
        if dim[1] != dim[2]
            throw(DimensionMismatch("Game board must be a square"))
        end
        this.states = states
        this.size = dim[1]
        this.row = row
        # calculate the turn
        this.turn = 0
        for i in states
            (i != 0) && (b.turn += 1)
        end
        this.isrunning = this.turn < this.size ^ 2 && check(this) == 0 ? true : false;
        return this
    end
end

function move(board::Board, position::Int)
    board.states[position] = board.turn % 2 == 0 ? 1 : -1
    board.turn += 1
    return check(board)
end

function nocheck_move(board::Board, position::Int)
    board.states[position] = board.turn % 2 == 0 ? 1 : -1
    board.turn += 1
    nothing
end

function showgame(board::Board)
    println("> Turn $(board.turn)")
    for i in 1:(board.size^2)
        print(" ", board.states[i] == 1 ? "X" :
                    board.states[i] == -1 ? "O" : "-")
        if ((i - 1) % board.size == board.size - 1)
            println()
        end
    end
    println()
end

function diagCheckAsc(b::Board, x::Int, y::Int)
    inarow = 1
    while x < b.size && y > 1
        if b.states[x, y] == b.states[x + 1, y - 1] != 0
            inarow += 1
            (inarow >= b.row) && (return b.states[x, y])
        else
            inarow = 1
        end
        x += 1
        y -= 1
    end
    return 0
end

function diagCheckDesc(b::Board, x::Int, y::Int)
    inarow = 1
    while x < b.size && y < b.size
        if b.states[x, y] == b.states[x + 1, y + 1] != 0
            inarow += 1
            # if inarow >= b.row
            #     return b.states[x, y]
            # end
            (inarow >= b.row) && (return b.states[x, y])
        else
            inarow = 1
        end
        x += 1
        y += 1
    end
    return 0
end

function diagcheck(b::Board)
    ksize = b.size - b.row + 1
    # descending
    res = diagCheckDesc(b, 1, 1)
    res != 0 && return res
    for j in 2:ksize
        res = diagCheckDesc(b, 1, j)
        res != 0 && return res
        res = diagCheckDesc(b, j, 1)
        res != 0 && return res
    end
    # ascending
    for j in 0:(ksize-2)
        res = diagCheckAsc(b, 1, b.row + j)
        res != 0 && return res
        res = diagCheckAsc(b, 2 + j, b.size)
        res != 0 && return res
    end
    res = diagCheckAsc(b, 1, b.size)
    res != 0 && return res
    # else
    return 0
end

# find a winner
function check(board::Board)::Int8
    # disable isrunning flag
    board.isrunning = false
    # check horizontal/vertical wins
    for j in 1:(board.size)
        σ = 1
        ρ = 1
        for i in 1:(board.size - 1)
            # rows
            if (board.states[i, j] == board.states[i + 1, j]) && (board.states[i, j] != 0)
                σ += 1
                if σ >= board.row
                    return board.states[i, j]
                end
            else
                σ = 1
            end
            # columns
            if (board.states[j, i] == board.states[j, i + 1]) && (board.states[j, i] != 0)
                ρ += 1
                if ρ >= board.row
                    return board.states[j, i]
                end
            else
                ρ = 1
            end
        end
    end

    diagres = diagcheck(board)
    diagres != 0 && return diagres

    if board.turn >= board.size ^ 2
        return 0
    end
    # re-enable isrunning flag
    board.isrunning = true
    return 0
end

### AI ###

# TODO: BE CAREFUL! Additional attributes may not be copied if changes
# are not modified here as well! (WARNING #001)

function quietcopy(b::Board)
    this = Board(b.size, row=b.row)
    this.states = copy(b.states)
    this.row = b.row
    this.turn = b.turn
    this.isrunning = this.turn < this.size ^ 2 && check(this) == 0 ? true : false;
    return this
end

# (WARNING #001)

function reset!(b::Board, states::Array{Int8})
    b.states = states
    b.turn = 0
    for i in states
        (i != 0) && (b.turn += 1)
    end
    b.isrunning = true

    nothing
end

function incrTpl(d::Dict, pos::Int; a=1, b=1)
    d[pos] =
    let
        x = get(d, pos, (0, 0));
        (x[1]+a, x[2]+b);
    end
end

# WARNING: VERIFY COLUMN MAJOR BEHAVIOUR!
# EXPERIMENTAL NODEMOVE

function nodemove!(board::Board, pos::Int; nocheck=false)
    mv = 0
    for i in 1:board.size^2
        if board.states[i] == 0
            mv += 1
            (mv == pos) && (return (nocheck ? nocheck_move(b, i) : move(b, i)))
        end
    end
    throw("Nodemove is broken!")
end

# WARNING: UCT WORKS DIFFERENTLY NOW

function selection(ptr::Node, game::Board)::Node
    # Select the most promising node
    # until you find a leaf
    # starting from some given node

    while !isempty(ptr.children)
        # println("Okay, we have $([p for p in ptr.children]). Which one is the best?")
        best_i = indmax(UCT.(ptr.children))
        ptr = ptr.children[best_i]
        nodemove!(game, best_i, nocheck=true)
    end
    return ptr
end

function expansion(ptr::Node, game::Board)
    # Unless leaf node ends the game
    # expand it by number of possible moves
    # and choose one of the added nodes randomly

    """ check if game ended here """
    winner = check(game)
    game.isrunning || return ptr, winner

    newlen = length(ptr.parent.children) - 1
    # WARNING: This may be a wrong idea
    # ptr.children = Node[Node(ptr) for i in 1:newlen]
    expandnode(ptr)
    move_i = rand(1:newlen)
    ptr = ptr.children[move_i]
    winner = nodemove!(game, move_i)
    # no winner yet === 0
    return ptr, winner
end

function simulation(game::Board, result::Int8)::Int8
    # Perform a simulation starting from
    # the randomly chosen node and return
    # who won that playout

    while game.isrunning
        result = nodemove!(game, rand(1:(game.size ^ 2 - game.turn)))
    end

    return result
end

function backpropagation(ptr::Node, gameptr::Node, result::Int8)
    # Update information to the parent nodes
    # up to the given node increasing visits counter
    # and increasing wins for winner's nodes
    global statsMap

    increment = result != 0 ? 1 : coinflip()

    while ptr != gameptr
        incrTpl(statsMap, ptr.states, a=increment, b=1)
        ptr = ptr.parent
        increment = (increment + 1) % 2
    end
    incrTpl(statsMap, ptr.states, a=increment, b=1)
    return ptr
end

function ai_turn(t::Tree, game::Board; timeLimit=1)
    g = quietcopy(game)
    timeLimit *= 1e9
    t0 = time_ns()
    # for i in 1:10000
    while time_ns() - t0 < timeLimit
        reset!(g, game.states)
        ptr = selection(t.ptr, g)
        ptr, winner = expansion(ptr, g)
        winner = simulation(g, winner)
        ptr = backpropagation(ptr, t.ptr, winner)
    end

    # select_best(game, update=true)
    println("Best move would be...")

    nothing
end

function coinflip()::Int8
    return rand(0:1)
end

# WARNING: THIS MAY HAVE WRONG UPDATE
# TODO: FIX indmax broadcast

function select_best(board::Board; update=false)
    pos = indmax(broadcast(n -> n.sims, board.ptr.children))
    # gameptr = gameptr.children[pos] # useless
    # println(gameptr)
    mv = 0
    for i in 1:board.size
        for j in 1:board.size
            if board.states[j, i] == 0
                mv += 1
                if mv == pos
                    legal_move = (i - 1) * board.size + j
                    update && (board.ptr = board.ptr.children[pos]; move(board, legal_move))
                    return legal_move
                end
            end
        end
    end
    nothing
end

nothing
