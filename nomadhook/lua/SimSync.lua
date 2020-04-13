do

local oldResetSyncTable = ResetSyncTable
function ResetSyncTable()
    oldResetSyncTable()

    -- new special ability syncs
    Sync.UpdateSpecialAbilityUI = {}
    
    -- legacy special ability syncs
    Sync.RemoveStaticDecal = {}

    Sync.VOUnitEvents = {}
    Sync.VOEvents = {}
end

UpdateSpecialAbilityUI = function(army, brainSpecialAbilities, unitSpecialAbilities)
    if army ~= nil and brainSpecialAbilities and unitSpecialAbilities then
        table.insert(Sync.UpdateSpecialAbilityUI, {BrainAbilitiesTable = brainSpecialAbilities, UnitAbilitiesTable = unitSpecialAbilities, Army = army})
    end
end

function RemoveStaticDecal(army, decalKeys)
    if army ~= nil then
        table.insert(Sync.RemoveStaticDecal, { Army = army, DecalKeys = decalKeys })
    end
end

function AddVOUnitEvent(unit, event)
    if unit and event then
        if unit.Army ~= nil then
            table.insert(Sync.VOUnitEvents, { Army = unit.Army, UnitId = unit.EntityId, Event = event })
        end
    end
end

function AddVOEvent(army, event)
    if event and army ~= nil then
        table.insert(Sync.VOEvents, { Army = army, Event = event })
    end
end

end
