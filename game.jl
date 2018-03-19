using Base

abstract type Game end

mutable struct Board <: Game
    xdim::Int64
    states::Array{Int8, 2}
    turn::Int64
    isrunning::Bool
    row::Int64
    players::Tuple
    last_move::Int64
    show::Function
    make_turn::Function
    move::Function

    function init!(this)
        this.players = (nothing, nothing)
        this.last_move = -1

        this.move = function(position::Int64)
            this.states[position] = this.turn % 2 == 0 ? 1 : -1
            this.turn += 1
            this.last_move = position
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
        this.isrunning = this.turn < 9 && check(this) == 0 ? true : false;

        init!(this)

        return this
    end
end

function Base.show(io::IO, b::Board)
    print(io, "Board<$(b.xdim)x$(b.xdim)> Condition: $(b.row) in a row\nturn: $(b.turn)\nactive: $(b.isrunning)\nplayers: $(b.players)\nlast move index: $(b.last_move)")
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
    b.last_move = -1
end

# transposed array
function reset!(b::Board, states::Array{Int8}; active=true, last_move=-1)
    b.states = states'
    b.turn = 0
    for i in states
        (i != 0) && (b.turn += 1)
    end
    b.isrunning = active
    b.last_move = last_move
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
    # diagonals (hard-coded for 3x3)
    # TODO: implement general-case checking
    if board.states[1, 1] == board.states[2, 2] == board.states[3, 3] != 0
        return board.states[1, 1]
    end
    if board.states[1, 3] == board.states[2, 2] == board.states[3, 1] != 0
        return board.states[1, 3]
    end
    # check if any turn is left
    if board.turn >= board.xdim ^ 2
        return 0
    end
    # re-enable isrunning flag
    board.isrunning = true
    return 0
end

function set_players!(game::Game, players::Tuple)
    @assert length(players) == 2
    game.players = players
    game.players[1].mark = Int8(1)
    game.players[2].mark = Int8(-1)
end
