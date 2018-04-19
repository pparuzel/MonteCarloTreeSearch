# Monte Carlo Tree Search

**How to**:
1. `$ julia -i main.jl`
2. `demo()` to run AI battle on 3x3 TicTacToe, three-in-a-row version

**Quick doc**:  
`function demo(;size=3, inrow=3, time=(1, 1), one=nothing, two=nothing)` 
* size - board size  
* inrow - winning condition  
* time - tuple with time for player1 and player2 respectively  
* one - player "one" AI brain  
* two - player "two" AI brain
  
`Tree(width::Int; explrate=1, rave=0.1)` (**Tree is basically AI's brain**)
* width - amount of legal moves (for empty 3x3 TicTacToe it is 9)
* explrate - exploration rate
* rave - MC-RAVE optimization parameter

**Other possible launches**:
+ `demo(size=5, inrow=4)`
+ `demo(time=(0.3, 0.3))`
+ `ai1 = Tree(9, rave=0.2);` `mcts(ai1, Game(3), seconds=60);` `demo(one=ai1);`

