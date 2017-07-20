do

-- TODO: find a good way to support other faction taunts

local NomadsTaunts = { 65, }

AITaunts = table.insert( AITaunts, NomadsTaunts )

local oldGetEngineerFaction = GetEngineerFaction

function GetEngineerFaction(engineer)
    local engyfaction =  oldGetEngineerFaction(engineer)
    if engyfaction ~= false then
        return engyfaction
    elseif EntityCategoryContains(categories.NOMADS, engineer) then
        return 'Nomads'
    else
        return false
    end
end

end