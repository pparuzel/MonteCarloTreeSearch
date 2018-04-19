# CONFIG

function configure(; ties=:coinflip;)
    global coinflip
    if ties == :coinflip
        coinflip() = Int(rand(Bool))
    elseif ties == :loss
        coinflip() = 0
    elseif ties == :win
        coinflip() = 1
    else
        nothing
    end

    nothing
end
