include("game.jl")
include("ai.jl")
include("player.jl")

function pvp()
    tictactoe = Board(3, row=3)
    tictactoe.show()
    player = Player()
    tictactoe.players = (player, player)

    while tictactoe.isrunning
        tictactoe.make_turn()
        tictactoe.show()
    end
end

function test_template()
    # Template board
    intboard = Int8[ 1 -1  0;
                    -1  1  0;
                     1 -1 -1]
    board = Board(intboard, row=3)
    board.show()
    println("Winner: ", check(board))
end

function pve()
    aidb = AI[]
    tictactoe = Board(3, row=3)
    tictactoe.show()
    ai = AI(9, plays=tictactoe)
    player = Player()
    set_players!(tictactoe, (player, ai))

    while tictactoe.isrunning
        tictactoe.make_turn()
        tictactoe.show()
        push!(aidb, deepcopy(ai))
    end

    println("AI.MARK ", ai.mark)
    println("Winner: ", check(tictactoe))
    return aidb
end

function test_selection()
    ai = AI(3, plays=Board(3))
    ptr = ai.tree.root
    # tree with root and two children
    ptr.wins = 2; ptr.sims = 2;
    ptr.children = Node[Node(ptr), let; tmp = Node(ptr);
    tmp.wins = 2; tmp.sims = 2; tmp; end]
    #
    ptr = selection(ai.gameptr, ai.game);
    println(ptr)
    ai.game.show()
    println(ai.tree)
end

function test_expansion()
    ai = AI(3, plays=Board(3))
    ptr = ai.tree.root
    # tree with root and children
    ptr.wins = 2; ptr.sims = 2;
    ptr.children = Node[(Node(ptr) for i in 1:4)..., let; tmp = Node(ptr);
    tmp.wins = 2; tmp.sims = 2; tmp; end, (Node(ptr) for i in 1:4)...]
    #
    ptr = selection(ai.gameptr, ai.game);
    println(ptr)
    ai.game.show()
    expansion(ptr, ai.game)
    println(ai.tree)
end

function test_expansion2()
    ai = AI(3, plays=Board(3))
    ptr = ai.tree.root
    # tree with root and children
    ptr.wins = 2; ptr.sims = 2;
    ptr.children = Node[(Node(ptr) for i in 1:4)..., let; tmp = Node(ptr);
    tmp.wins = 2; tmp.sims = 2; tmp; end, (Node(ptr) for i in 1:4)...]
    #
    ptr = selection(ai.gameptr, ai.game)
    expansion(ptr, ai.game)
    ptr = selection(ai.gameptr, ai.game)
    expansion(ptr, ai.game)

    println(ai.tree)
end

function test_simulation()
    ai = AI(3, plays=Board(3))
    ptr = ai.tree.root
    # tree with root and children
    ptr.wins = 2; ptr.sims = 2;
    ptr.children = Node[(Node(ptr) for i in 1:4)..., let; tmp = Node(ptr);
    tmp.wins = 2; tmp.sims = 2; tmp; end, (Node(ptr) for i in 1:4)...]
    #
    ptr = selection(ai.gameptr, ai.game)
    res = expansion(ptr, ai.game)
    res = simulation(ai.game, res)
    # println(res)
    res
end

function test_probability()
    b = Board(3)
    result = [0 0 0]
    for i in 1:10000
        reset!(b, Int8[1 1 -1; -1 -1 0; 1 1 0])
        res = simulation(b, Int8(-1))
        result[res + 2] += 1
    end
    println(b)
    # println(result)
    result
end

function test_probability2()
    b = Board(3)
    result = [0 0 0]
    ai = nothing; aigame = nothing
    for i in 1:10000
        reset!(b)
        ai = AI(3, plays=b)
        ptr = ai.tree.root
        # tree with root and children
        ptr.wins = 2; ptr.sims = 2;
        ptr.children = Node[(Node(ptr) for i in 1:4)..., let; tmp = Node(ptr);
        tmp.wins = 2; tmp.sims = 2; tmp; end, (Node(ptr) for i in 1:4)...]
        ptr = selection(ai.gameptr, ai.game)
        res = expansion(ptr, ai.game)
        aigame = deepcopy(ai.game)
        res = simulation(ai.game, res)
        result[res + 2] += 1
    end
    println(b)
    # println(result)
    Dict(:result => result, :board => b, :ai => ai, :aigame => aigame)
end

function test_mcts()
    t = Tree(5)
    intboard = Int8[ 1  1 -1;
                    -1 -1  1;
                     1  0  0]
    g = Board(intboard, row=3, quiet=true)
    g.show()
    winner = 999
    for i in 1:10
        g = Board(3, row=3, quiet=true)
        ptr = selection(t.root, g)
        ptr, winner = expansion(ptr, g)
        winner = simulation(g, winner)
        backpropagation(ptr, t.root, winner)
    end

    g2 = Board(3, row=3, quiet=true)
    answer = select_best(t.root, g2)
    println("Best next move is $answer")
    nodemove!(g2, answer)
    g2.show()

    Dict(:r => winner, :b => g, :t => t)
end

# pvp()
# pve()
# test_template()
# test_selection()
# test_expansion()
# test_expansion2()
# test_simulation()
# test_probability()
# test_probability2()
