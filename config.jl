# CONFIG

function configure(; ties=:coinflip)
    global coinflip
    if ties == :coinflip
        coinflip = function() return Int(rand(Bool)) end
    elseif ties == :loss
        coinflip = function() return 0 end
    elseif ties == :win
        coinflip = function() return 1 end
    else
        nothing
    end

    nothing
end
