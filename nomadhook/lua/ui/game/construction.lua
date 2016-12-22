do


local oldGetEnhancementPrefix = GetEnhancementPrefix

function GetEnhancementPrefix(unitID, iconID)
    local prefix = ''
    if string.sub(unitID, 2, 2) == 'N' or string.sub(unitID, 2, 2) == 'n' then
        prefix = '/game/nomad-enhancements/'..iconID
    else
        prefix = oldGetEnhancementPrefix(unitID, iconID)
    end
    return prefix
end



end