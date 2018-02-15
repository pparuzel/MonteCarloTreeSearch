abstract type Game end

mutable struct Board <: Game
    dim::Int64
    states::Array{Int8, 2}
    turn::Int64
    isrunning::Bool
    row::Int64
    show::Function
    make_turn::Function
    move::Function
    players::Tuple

    function init!(this)
        this.players = (nothing, nothing)

        this.move = function(position::Int64)
            put!(this, position)
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
                if ((i - 1) % this.dim == this.dim - 1)
                    println()
                end
            end
            println()
        end
    end

    function Board(dim::Int64; row=3)
        this = new()
        println("Initilizing TicTacToe board...")
        this.dim = dim
        this.row = row
        this.states = zeros(Int8, (dim, dim))
        this.turn = 0
        this.isrunning = true

        init!(this)

        println("Board<$(this.dim)x$(this.dim)> Condition: $(this.row) in a row")

        return this
    end

    function Board(board::Array{Int8, 2}; row=3)
        this = new()
        println("Initializing TicTacToe board...")
        bsize = size(board)
        if bsize[1] != bsize[2]
            throw(DimensionMismatch("Game board must be a square"))
        end
        this.dim = bsize[1]
        this.row = row
        this.states = board
        # calculate turn
        this.turn = 0
        for i in 1:length(board)
            this.turn += Int64(board[i] != 0)
        end
        this.isrunning = this.turn < 9 && check(this) == 0 ? true : false;

        init!(this)

        println("Board<$(this.dim)x$(this.dim)> Condition: $(this.row) in a row")

        return this
    end
end

# find a winner
function check(board::Board)::Int8
    # disable isrunning flag
    board.isrunning = false
    # check if any turn is left
    if board.turn >= board.dim ^ 2
        board.isrunning = false
        return 0
    end
    # check horizontal/vertical wins
    for j in 1:(board.dim)
        σ = 1
        ρ = 1
        for i in 1:(board.dim - 1)
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
    # re-enable isrunning flag
    board.isrunning = true
    return 0
end

function put!(board::Board, posX::Int64, posY::Int64)
    board.states[posX, posY] = board.turn % 2 == 0 ? 1 : -1
    board.turn += 1
end

function put!(board::Board, pos::Int64)
    board.states[pos] = board.turn % 2 == 0 ? 1 : -1
    board.turn += 1
end

function set_players(game::Game, players::Tuple)
    @assert length(players) == 2
    game.players = players
    game.players[1].mark = Int8(1)
    game.players[2].mark = Int8(-1)
end
