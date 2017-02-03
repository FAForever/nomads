local Factions = import('/lua/factions.lua').Factions
local FactionInUnitBpToKey = import('/lua/factions.lua').FactionInUnitBpToKey

local OldOnRolloverHandler = OnRolloverHandler
function OnRolloverHandler(button, state)
    OldOnRolloverHandler(button, state)
    if not options.gui_draggable_queue ~= 0 and not button.Data.type == 'queuestack' and not prevSelection and not EntityCategoryContains(categories.FACTORY, prevSelection[1]) then
        UnitViewDetail.Hide()
    end
end


--hooking to fix enhancement prefixes not accounting for nomads
local oldGetEnhancementPrefix = GetEnhancementPrefix

function GetEnhancementPrefix(unitID, iconID)
    local prefix = ''
    if string.sub(unitID, 2, 2) == 'N' or string.sub(unitID, 2, 2) == 'n' then
        prefix = '/game/nomads-enhancements/'..iconID
    else
        prefix = oldGetEnhancementPrefix(unitID, iconID)
    end
    return prefix
end