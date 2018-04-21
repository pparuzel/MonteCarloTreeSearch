mutable struct Game
    states::Array{Int8, 2}
    turn::Int
    size::Int
    inarow::Int
    isrunning::Bool

    function Game(size::Int; row=3)
        return new(zeros(Int8, size, size), 0, size, row, true)
    end

    function Game(states::Array{Int8, 2}, turn::Int, size::Int, row::Int, active=true)
        return new(states, turn, size, row, active)
    end
end

Base.show(io::IO, g::Game) = print(io, "Game<$(g.size)x$(g.size)> $(g.isrunning ? "running" : "gameover")…")

function makecopy(g::Game)
    return Game(copy(g.states), g.turn, g.size, g.inarow, g.isrunning)
end

function nodemove(g::Game, pos::Int; with_check=true)
    # # DEBUG
    # if pos > (g.size^2 - g.turn)
    #     throw("illegal nodemove: $(pos). position is unavailable")
    # end
    for i in 1:length(g.states)
        mv = 0
        for i in 1:length(g.states)
            if g.states[i] == 0
                mv += 1
                (mv == pos) && (return legalmove(g, i, with_check=with_check))
            end
        end
    end
end

# NOTE: Tested
function legalmove(g::Game, pos::Int; with_check=true)
    # # DEBUG
    # if !g.isrunning
    #     throw("illegal move: game is over ($pos)")
    # end
    # if g.states[pos] != 0
    #     throw("illegal move: $(pos). position is taken")
    # end
    g.states[pos] += g.turn % 2 == 0 ? 1 : -1
    g.turn += 1
    (with_check) && (return check(g))
    nothing
end

# NOTE: Tested
# Shortly named utility function (SHOW BOARD)
function sh(g::Game)
    println("Board")
    for i in 1:length(g.states)
        if g.states[i] == 1
            print("X ")
        elseif g.states[i] == -1
            print("O ")
        else
            print("- ")
        end
        (i % g.size == 0) && println()
    end
end

# NOTE: Tested
function diagCheckAsc(g::Game, x::Int, y::Int)
    inarow = 1
    while x < g.size && y > 1
        if g.states[x, y] == g.states[x + 1, y - 1] != 0
            inarow += 1
            (inarow >= g.inarow) && (return g.states[x, y])
        else
            inarow = 1
        end
        x += 1
        y -= 1
    end
    return 0
end

# NOTE: Tested
function diagCheckDesc(g::Game, x::Int, y::Int)
    inarow = 1
    while x < g.size && y < g.size
        if g.states[x, y] == g.states[x + 1, y + 1] != 0
            inarow += 1
            (inarow >= g.inarow) && (return g.states[x, y])
        else
            inarow = 1
        end
        x += 1
        y += 1
    end
    return 0
end

# NOTE: Tested
function diagcheck(b::Game)
    ksize = b.size - b.inarow + 1
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
        res = diagCheckAsc(b, 1, b.inarow + j)
        res != 0 && return res
        res = diagCheckAsc(b, 2 + j, b.size)
        res != 0 && return res
    end
    res = diagCheckAsc(b, 1, b.size)
    res != 0 && return res
    # else
    return 0
end

# NOTE: Tested
function check(board::Game)::Int8
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
                if σ >= board.inarow
                    return board.states[i, j]
                end
            else
                σ = 1
            end
            # columns
            if (board.states[j, i] == board.states[j, i + 1]) && (board.states[j, i] != 0)
                ρ += 1
                if ρ >= board.inarow
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
