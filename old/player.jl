mutable struct Player
    mark::Int8
    choice::Function

    function Player()
        this = new()
        this.mark = 0
        this.choice = function()
            player_choice = parse(Int64, readline())
            return player_choice
        end
        return this
    end
end
