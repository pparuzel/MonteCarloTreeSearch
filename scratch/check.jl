function diagCheckAsc(b::Board, x::Int64, y::Int64)
    # println("A($x, $y)")
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

function diagCheckDesc(b::Board, x::Int64, y::Int64)
    # println("D($x, $y)")
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
