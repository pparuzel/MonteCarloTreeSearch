type Board
    dim::Int64
    states::Array{Int8, 2}
    turn::Int64
    active::Bool
    row::Int64
    show::Function

    function init!(this)
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
        this.active = true

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
        this.active = this.turn < 9 && check(this) == 0 ? true : false;

        init!(this)

        println("Board<$(this.dim)x$(this.dim)> Condition: $(this.row) in a row")

        return this
    end
end

# find a winner
function check(board::Board)
    for j in 1:(board.dim)
        σ = 1
        ρ = 1
        for i in 1:(board.dim - 1)
            # rows
            if board.states[i, j] == board.states[i + 1, j]
                σ += 1
                if σ >= board.row
                    return board.states[i, j]
                end
            else
                σ = 1
            end
            # columns
            if board.states[j, i] == board.states[j, i + 1]
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
    return 0
end

function put!(board::Board, posX::Int64, posY::Int64)
    board.states[posX, posY] = board.turn % 2 == 0 ? 1 : -1
    board.turn += 1
    if board.turn >= board.dim ^ 2
        board.active = false
    end
end

function put!(board::Board, pos::Int64)
    board.states[pos] = board.turn % 2 == 0 ? 1 : -1
    board.turn += 1
    if board.turn >= board.dim ^ 2
        board.active = false
    end
end
