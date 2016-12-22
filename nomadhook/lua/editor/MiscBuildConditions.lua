# Adding function that translates a faction name to a faction index, custom faction compatibility

local Factions = import('/lua/factions.lua').Factions


function IsFactionCat(aiBrain, FactionCategory1, FactionCategory2, FactionCategory3)
    local facIndex = aiBrain:GetFactionIndex()
    local facCat = Factions[facIndex].Category
    #LOG('*DEBUG: IsFactionCat: army '..repr(facIndex)..' is '..repr(facCat)..'. Looking for '..repr(FactionCategory1)..' or '..repr(FactionCategory2)..' or '..repr(FactionCategory3))
    return (facCat == FactionCategory1 or facCat == FactionCategory2 or facCat == FactionCategory3)
end
