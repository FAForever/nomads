do

-- TODO: find a good way to support other faction taunts

local NomadsTaunts = { 65, }

AITaunts = table.insert( AITaunts, NomadsTaunts )

local oldGetEngineerFaction = GetEngineerFaction

function GetEngineerFaction(engineer)
    local engyfaction =  oldGetEngineerFaction(engineer)
    if engyfaction == false then
        if EntityCategoryContains(categories.NOMADS, engineer) then
            return 'Nomads'
        else
            return false
        end
    else
        return engyfaction
    end
end

end