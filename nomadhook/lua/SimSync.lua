do

local oldResetSyncTable = ResetSyncTable
function ResetSyncTable()
    oldResetSyncTable()

    -- new special ability syncs
    Sync.UpdateSpecialAbilityUI = {}
    
    -- legacy special ability syncs
    Sync.StartAbilityCoolDown = {}
    Sync.StopAbilityCoolDown = {}
    Sync.RemoveStaticDecal = {}

    Sync.VOUnitEvents = {}
    Sync.VOEvents = {}
end

UpdateSpecialAbilityUI = function(army, brainSpecialAbilities, unitSpecialAbilities)
    if army ~= nil and brainSpecialAbilities and unitSpecialAbilities then
        table.insert(Sync.UpdateSpecialAbilityUI, {BrainAbilitiesTable = brainSpecialAbilities, UnitAbilitiesTable = unitSpecialAbilities, Army = army})
    end
end

StartAbilityCoolDown = function(army, ability)
    if army ~= nil and ability then
        table.insert(Sync.StartAbilityCoolDown, { AbilityName = ability, Army = army })
    end
end

StopAbilityCoolDown = function(army, ability)
    if army ~= nil and Ability then
        table.insert(Sync.StopAbilityCoolDown, { AbilityName = ability, Army = army })
    end
end

function RemoveStaticDecal(army, decalKeys)
    if army ~= nil then
        table.insert(Sync.RemoveStaticDecal, { Army = army, DecalKeys = decalKeys })
    end
end

function AddVOUnitEvent(unit, event)
    if unit and event then
        local army = unit:GetArmy()
        if army ~= nil then
            table.insert(Sync.VOUnitEvents, { Army = army, UnitId = unit:GetEntityId(), Event = event })
        end
    end
end

function AddVOEvent(army, event)
    if event and army ~= nil then
        table.insert(Sync.VOEvents, { Army = army, Event = event })
    end
end

end
