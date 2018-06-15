# CONFIG

function configure(; ties=:coinflip, nodeformat=:combined)
    global coinflip
    if ties == :coinflip
        coinflip() = Int(rand(Bool))
    elseif ties == :loss
        coinflip() = 0
    elseif ties == :win
        coinflip() = 1
    elseif ties == :half
        coinflip() = 0.5
    else
        nothing
    end

    if nodeformat == :combined
        Base.show(io::IO, x::Node) = print(io, "Node($(x.wins+x.winsAMAF)/$(x.sims+x.simsAMAF), $(length(x.children))$(x.parent == nothing ? ", root" : ""))")
    elseif nodeformat == :sum
        Base.show(io::IO, x::Node) = print(io, "Node($(x.wins)+$(x.winsAMAF)/$(x.sims)+$(x.simsAMAF), $(length(x.children))$(x.parent == nothing ? ", root" : ""))")
    elseif nodeformat == :separate
        Base.show(io::IO, x::Node) = print(io, "Node($(x.wins)/$(x.sims), amaf: $(x.winsAMAF)/$(x.simsAMAF) $(length(x.children))$(x.parent == nothing ? ", root" : ""))")
    end

    nothing
end
