do

local oldResetSyncTable = ResetSyncTable
function ResetSyncTable()
    oldResetSyncTable()

    # special ability syncs
    Sync.AddSpecialAbility = {}
    Sync.RemoveSpecialAbility = {}
    Sync.EnableSpecialAbility = {}
    Sync.DisableSpecialAbility = {}
    Sync.StartAbilityCoolDown = {}
    Sync.StopAbilityCoolDown = {}
    Sync.SetAbilityUnits = {}
    Sync.SetAbilityRangeCheckUnits = {}
    Sync.RemoveStaticDecal = {}

    Sync.VOUnitEvents = {}
    Sync.VOEvents = {}
end

AddSpecialAbility = function(army, ability)
    if army != nil and ability then
        table.insert(Sync.AddSpecialAbility, { AbilityName = ability, Army = army })
    end
end

RemoveSpecialAbility = function(army, ability)
    if army != nil and ability then
        table.insert(Sync.RemoveSpecialAbility, { AbilityName = ability, Army = army })
    end
end

EnableSpecialAbility = function(army, ability)
    if army != nil and ability then
        table.insert(Sync.EnableSpecialAbility, { AbilityName = ability, Army = army })
    end
end

DisableSpecialAbility = function(army, ability)
    if army != nil and ability then
        table.insert(Sync.DisableSpecialAbility, { AbilityName = ability, Army = army })
    end
end

StartAbilityCoolDown = function(army, ability)
    if army != nil and ability then
        table.insert(Sync.StartAbilityCoolDown, { AbilityName = ability, Army = army })
    end
end

StopAbilityCoolDown = function(army, ability)
    if army != nil and Ability then
        table.insert(Sync.StopAbilityCoolDown, { AbilityName = ability, Army = army })
    end
end

function SetAbilityUnits(army, ability, units)
    if army != nil and ability and units then
        table.insert(Sync.SetAbilityUnits, { Army = army, AbilityName = ability, UnitIds = units })
    end
end

function SetAbilityRangeCheckUnits(army, ability, units)
    if army != nil and ability and units then
        table.insert(Sync.SetAbilityRangeCheckUnits, { Army = army, AbilityName = ability, UnitIds = units })
    end
end

function RemoveStaticDecal(army, decalKeys)
    if army != nil then
        table.insert(Sync.RemoveStaticDecal, { Army = army, DecalKeys = decalKeys })
    end
end

function AddVOUnitEvent(unit, event)
    if unit and event then
        local army = unit:GetArmy()
        if army != nil then
            table.insert(Sync.VOUnitEvents, { Army = army, UnitId = unit:GetEntityId(), Event = event })
        end
    end
end

function AddVOEvent(army, event)
    if event and army != nil then
        table.insert(Sync.VOEvents, { Army = army, Event = event })
    end
end

end
