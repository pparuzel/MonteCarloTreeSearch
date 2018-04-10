# Game has the TREE

#= NODE =#

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

#= NODE =#
#= TREE =#

mutable struct Tree
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

#= TREE =#
#= GAME =#

using Base

abstract type Game end

mutable struct Board <: Game
    xdim::Int64
    turn::Int64
    row::Int64
    states::Array{Int8, 2}
    isrunning::Bool
    players::Tuple
    tree::Tree
    ptr::Node
    show::Function
    make_turn::Function
    move::Function

    function init!(this)
        this.players = (nothing, nothing)

        this.move = function(position::Int64)
            this.states[position] = this.turn % 2 == 0 ? 1 : -1
            this.turn += 1
            check(this)
        end

        this.make_turn = function()
            playerid = this.turn % 2 == 0 ? 1 : 2
            this.move(this.players[playerid].choice())
        end

        this.show = function()
            println("> Turn $(this.turn)")
            for i in 1:length(this.states)
                print(" ", this.states[i] == 1 ? "X" :
                            this.states[i] == -1 ? "O" : "-")
                if ((i - 1) % this.xdim == this.xdim - 1)
                    println()
                end
            end
            println()
        end
    end

    function Board(xdim::Int64; row=3, quiet=false)
        this = new()
        (!quiet) && (println("Initilizing TicTacToe board..."))
        this.xdim = xdim
        this.row = row
        this.states = zeros(Int8, (xdim, xdim))
        this.turn = 0
        this.isrunning = true
        this.tree = Tree(xdim * xdim)
        this.ptr = this.tree.root

        init!(this)

        return this
    end

    function Board(board::Array{Int8, 2}; row=3, quiet=false)
        this = new()
        board = board.'
        (!quiet) && (println("Initializing TicTacToe board..."))
        bsize = size(board)
        if bsize[1] != bsize[2]
            throw(DimensionMismatch("Game board must be a square"))
        end
        this.xdim = bsize[1]
        this.row = row
        this.states = board
        # calculate turn
        this.turn = 0
        for i in 1:length(board)
            this.turn += Int64(board[i] != 0)
        end
        this.tree = Tree(this.xdim ^ 2 - this.turn)
        this.ptr = this.tree.root
        this.isrunning = this.turn < this.xdim ^ 2 && check(this) == 0 ? true : false;

        init!(this)

        return this
    end
end

function quietcopy(b::Board)
    this = Board(b.xdim, row=b.row, quiet=true)
    this.states = copy(b.states)
    this.row = b.row
    # calculate turn
    this.turn = 0
    for i in 1:length(this.states)
        this.turn += Int64(this.states[i] != 0)
    end
    this.isrunning = this.turn < this.xdim ^ 2 && check(this) == 0 ? true : false;

    # init!(this)

    this.players = b.players
    this.ptr = b.ptr

    return this
end

function Base.show(io::IO, b::Board)
    print(io, "Board<$(b.xdim)x$(b.xdim)> Condition: $(b.row) in a row\nturn: $(b.turn)\nactive: $(b.isrunning)\nplayers: $(b.players)")
end

function nodemove!(board::Board, pos::Int64)
    mv = 0
    for i in 1:board.xdim
        for j in 1:board.xdim
            if board.states[j, i] == 0
                mv += 1
                if mv == pos
                    return board.move((i - 1) * board.xdim + j)
                end
            end
        end
    end
end

function reset!(b::Board)
    b.states = zeros(Int8, (b.xdim, b.xdim))
    b.turn = 0
    b.isrunning = true
end

# transposed array
function reset!(b::Board, states::Array{Int8}; active=true)
    b.states = states'
    b.turn = 0
    for i in states
        (i != 0) && (b.turn += 1)
    end
    b.isrunning = active
    nothing
end

# RAW RESET
function raw_reset!(b::Board, states::Array{Int8}; active=true)
    b.states = states
    b.turn = 0
    for i in states
        (i != 0) && (b.turn += 1)
    end
    b.isrunning = active
    nothing
end

# find a winner
function check(board::Board)::Int8
    # disable isrunning flag
    board.isrunning = false
    # check horizontal/vertical wins
    for j in 1:(board.xdim)
        σ = 1
        ρ = 1
        for i in 1:(board.xdim - 1)
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

    # diagonals (hard-coded for 3x3)
    # TODO: implement general-case checking
    # if board.states[1, 1] == board.states[2, 2] == board.states[3, 3] != 0
    #     return board.states[1, 1]
    # end
    # if board.states[1, 3] == board.states[2, 2] == board.states[3, 1] != 0
    #     return board.states[1, 3]
    # end

    # descending diags

    # ascending diags

    # check if any turn is left
    if board.turn >= board.xdim ^ 2
        return 0
    end
    # re-enable isrunning flag
    board.isrunning = true
    return 0
end

# function set_players!(game::Game, players::Tuple)
#     @assert length(players) == 2
#     game.players = players
# end

#= GAME =#
#= AI =#

using Base

function ai_turn(game::Game; timeLimit=1)
    # g = deepcopy(game)
    g = quietcopy(game)
    timeLimit *= 1e9
    t0 = time_ns()
    # for i in 1:10000
    while time_ns() - t0 < timeLimit
        reset!(g, game.states')
        ptr = selection(game.ptr, g)
        ptr, winner = expansion(ptr, g)
        winner = simulation(g, winner)
        ptr = backpropagation(ptr, game.ptr, winner)
    end

    select_best(game, update=true)

    nothing
end

function coinflip()::Int8
    return rand(0:1)
end

function select_best(board::Game; update=false)
    pos = indmax(broadcast(n -> n.sims, board.ptr.children))
    # gameptr = gameptr.children[pos] # useless
    # println(gameptr)
    mv = 0
    for i in 1:board.xdim
        for j in 1:board.xdim
            if board.states[j, i] == 0
                mv += 1
                if mv == pos
                    legal_move = (i - 1) * board.xdim + j
                    update && (board.ptr = board.ptr.children[pos]; board.move(legal_move))
                    return legal_move
                end
            end
        end
    end
    nothing
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
    return ptr, check(game)
end

function simulation(game::Game, result::Int8)::Int8
    # Perform a simulation starting from
    # the randomly chosen node and return
    # who won that playout

    while game.isrunning
        result = nodemove!(game, rand(1:(game.xdim ^ 2 - game.turn)))
    end

    return result
end

function backpropagation(ptr::Node, gameptr::Node, result::Int8)
    # Update information to the parent nodes
    # up to the given node increasing visits counter
    # and increasing wins for winner's nodes

    # result = abs(result)
    increment = result != 0 ? 1 : coinflip()

    while ptr != gameptr
        ptr.sims += 1
        # ptr.wins += (game.turn % 2 == 1 ? 1 : -1) * result
        ptr.wins += increment
        ptr = ptr.parent
        increment = (increment + 1) % 2
    end
    ptr.sims += 1
    ptr.wins += increment
    return ptr
end

#= AI =#
#= MORE =#

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

function depth(node::Node, _depth::Int64, level=0)
    (_depth == level) && println("-" ^ 2level, node)
    for n in node.children
        depth(n, _depth, level + 1)
    end
    nothing
end


# TODO: propozycja: sims + 1 w mianowniku


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

# function indexToNode(game::Game, last_move::Int64)
#     res = 0
#     for i in 1:length(game.states)
#         if game.states[i] == 0
#             res += 1
#             if i == last_move
#                 break
#             end
#         end
#     end
#     return res
# end

#= Player =#

 function player_turn()
    player_choice = parse(Int64, readline())
    return player_choice
end

#= Player =#
#= MORE =#

# intboard = Int8[ 1  0  0;
#                 -1  1  0;
#                  0  0 -1]
intboard = Int8[-1  0  1;
                 0  1  0;
                -1  0  0]

function main()
    global intboard
    game = Board(intboard, row=3, quiet=true)
    game.show()

    g = deepcopy(game)
    for i in 1:10000
        reset!(g, intboard)
        ptr         = selection(game.tree.root, g)
        ptr, winner = expansion(ptr, g)
        winner      = simulation(g, winner)
        ptr         = backpropagation(ptr, game.tree.root, winner)
    end

    game
end

function demo(;size=3, row=3, debug=true, time=1)
    tictactoe = Board(size, row=row)
    tictactoe.show()

    while tictactoe.isrunning
        ai_turn(tictactoe, timeLimit=time)
        debug && depth(tictactoe.ptr.parent, 1)
        tictactoe.show()
        # readline()
        # tictactoe.move(player.propose())
    end
end

function diagCheckAsc(b::Board, x::Int64, y::Int64)
    # println("A($x, $y)")
    inarow = 1
    while x < b.xdim && y > 1
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

function diagCheckDesc(b::Board, x::Int64, y::Int64)
    # println("D($x, $y)")
    inarow = 1
    while x < b.xdim && y < b.xdim
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
    ksize = b.xdim - b.row + 1
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
        res = diagCheckAsc(b, 2 + j, b.xdim)
        res != 0 && return res
    end
    res = diagCheckAsc(b, 1, b.xdim)
    res != 0 && return res
    # else
    return 0
end
# (1, row) (1, row+1) ... (1, xdim-1)
# (1, xdim)
# (2, xdim) (3, xdim) ... (xdim-row+1, xdim)

# g = main()

states = Int8[0 0 0 0 0 0;
              0 0 0 1 0 1;
              0 0 1 0 1 1;
              0 1 0 1 1 0;
              0 0 1 1 0 0;
              0 0 1 0 0 0]
numbs = Int8[1 2 3 4 5 6; 7 8 9 10 11 12; 13 14 15 16 17 18; 19 20 21 22 23 24; 25 26 27 28 29 30; 31 32 33 34 35 36]

tmp = Board(states, row=4)
println(diagcheck(tmp))
