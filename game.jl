type Board
    dim::Int64
    states::Array{Int8, 2}
    turn::Int64
    active::Bool
    row::Int64
    show::Function

    function Board(dim::Int64; row=3)
        this = new()
        println("Initilizing TicTacToe board...")
        this.dim = dim
        this.row = row
        this.states = zeros(Int64, (dim, dim))
        this.turn = 0
        this.active = true

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

        println("Board<$(this.dim)x$(this.dim)> Condition: $(this.row) in a row")

        return this
    end

    function Board(board::Array{Int8, 2}; row=3)
        this = new()
        println("Initializing TicTacToe board...")
        bsize = size(board)
        if bsize[0] != bsize[1]
            throw(DimensionMismatch())
        end
        this.dim = bsize[0]
        this.row = row
        this.states = board
        # calculate turn
        this.turn = 0
        for i in 1:length(board)
            this.turn += Int64(board[i] != 0)
        end
        this.active = ?
    end
end

# find a winner
function check(board::Board)
    for j in 1:(board.dim)
        σ = 1
        ρ = 1
        for i in 1:(board.dim - 1)
            if board.states[i, j] == board.states[i + 1, j]
                σ += 1
                if σ >= 3
                    return board.states[i, j]
                end
            else
                σ = 1
            end
            if board.states[i, j] == board.states[i, j + 1]
                ρ += 1
                if ρ >= 3
                    return board.states[i, j]
                end
            else
                ρ = 1
            end
        end
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
