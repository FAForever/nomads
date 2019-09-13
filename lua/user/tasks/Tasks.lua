-- Keeps some administrative values and has generic validation functions.

local AbilityDefinition = import('/lua/abilitydefinition.lua').abilities
local GetWorldViews = import('/lua/ui/game/worldview.lua').GetWorldViews
--local CM = import('/lua/ui/game/commandmode.lua')

function GetRangeCheckUnitsScript( TaskName )
    local army = GetFocusArmy()
    return GetAbilityUnitsFromTable(ArmyUnitAbilitiesTable[army], TaskName, true)
end

function MapReticulesToUnitIdsScript( TaskName, ReticulePositions, Units, UnitIds )
    -- Maps units to reticule positions so each unit can be given the most optimal position to fire its ability on. This is quite complex
    -- because we want to use the nearest unit for each reticule and also we consider the number of reticules the unit can handle at the
    -- same time.

    local UnitCapList = {}  -- lists keys to the Units table. Can contain the same key more than once if that unit has the capacity to
                            -- handle more than one reticule at the same time.

    -- compile UnitCapList table. Unit keys are added according to their capacity.
    local bp, cap
    local MaxRanges = {}
    local MinRanges = {}
    for k, unit in Units do

        bp = unit:GetBlueprint().SpecialAbilities
        if bp and bp[TaskName] and bp[TaskName].WantNumTargets then
            cap = bp[TaskName].WantNumTargets
        else
            cap = 1
        end

        for i=1, cap do
            table.insert(UnitCapList, k)
        end
    end
    -- for every reticule determine the nearest unassigned unit
    local ClosestUnitKeys = {}
    local pos, dist, ClosestDist, ClosestUnitKey
    for RetKey, RetPos in ReticulePositions do
        ClosestDist = nil
        ClosestUnitKey = nil
        for _, UnitKey in UnitCapList do
            if UnitCanFireAtPos(TaskName, Units[UnitKey], RetPos) then
                pos = Units[UnitKey]:GetPosition()
                dist = VDist2(pos[1], pos[3], RetPos[1], RetPos[3])
                if not ClosestDist or dist < ClosestDist then
                    ClosestDist = dist
                    ClosestUnitKey = UnitKey
                end
            end
        end
        if ClosestUnitKey then
            ClosestUnitKeys[RetKey] = ClosestUnitKey
            table.removeByValue(UnitCapList, ClosestUnitKey)  -- remove just assigned unit from the list. Notice that this removes 1 entry
        else                                                  -- in the table. Units with capacity > 1 will still be listed at least once more
            WARN('*DEBUG: MapReticulesToUnitIdsScript: couldnt map a unit to reticule '..repr(RetKey)..' for task '..repr(TaskName))
        end
    end

    -- TODO: If the idea of using the nearest units isn't the best then change it here.

    -- Find unit Ids. We need to return unit Ids, not keys of the Units table.
    local map = {}
    for RetKey, UnitKey in ClosestUnitKeys do
        map[RetKey] = Units[UnitKey]:GetEntityId()
    end

    return map
end

-- --------------------------------------------------

AbilityUnits = {}
AbilityRangeCheckUnits = {}
ArmyUnitAbilitiesTable = {}
--[[
ArmyUnitAbilitiesTable = {
    1 = { --Army ID
        12 = {--UnitID
            OrbitalBombardment = { --Ability
                AvailableNowUnit = true,
            },
        },
    },
}

--]]
UpdateArmyUnitsTable = function(unitAbilitiesTable)
    local army = GetFocusArmy()
    ArmyUnitAbilitiesTable[army] = unitAbilitiesTable
end

GetAvailableAbilityUnits = function(abilityName)
    -- TODO: consider energy needs. The Eye of Rianne needs energy to run so we may want to dynamically filter out units
    -- based on the current supply and energy available.
    local army = GetFocusArmy()
    return DoUnitSelectedFilter(abilityName, GetAbilityUnitsFromTable(ArmyUnitAbilitiesTable[army], abilityName, true))
end

--filters out units with abilities from a table.
GetAbilityUnitsFromTable = function(abilityTable, abilityName, AvailableNowOnly)
    if not AbilityDefinition[ abilityName ] then return false end
    
    local unitsTable = {}
    for unitID, abilityTypes in abilityTable do
        if abilityTypes[abilityName] and (not (abilityTypes[abilityName]['Enabled'] == false)) and (not AvailableNowOnly or abilityTypes[abilityName]['AvailableNowUnit'] > 0) then
            table.insert(unitsTable, unitID)
        end
    end
    return unitsTable
end

-- internal - GetAvailableAbilityUnits
-- filter out units that are not selected. uses Command data. Alternatively could use GetSelectedUnitIds from abilities.lua. not sure whats better.
DoUnitSelectedFilter = function(abilityName, unitIds)
    local mode = import('/lua/ui/game/commandmode.lua').GetCommandMode() --TODO:after fixing this entire file move the import somewhere sane
    if unitIds and mode[1] == 'order' and mode[2].TaskName and AbilityDefinition[ mode[2].TaskName ] and mode[2].Behaviour.UseSelected and table.getn(mode[2].SelectedUnits) > 0 then
        unitIds = table.filter(unitIds, function(v) return table.find(mode[2].SelectedUnits, v) end)
    end
    return unitIds
end

SetAbilityRangeCheckUnits = function(abilityName, army, unitIds)
    -- used to add a single unit id for range checking, or more than one (provided as a table)
    --LOG('*DEBUG: SetAbilityRangeCheckUnits() abilityName = '..repr(abilityName)..' army = '..repr(army)..' unitIds = '..repr(unitIds))
    if army and unitIds and army >= 0 and army <= 16 and AbilityDefinition[abilityName] then
        if not AbilityRangeCheckUnits[abilityName] then
            AbilityRangeCheckUnits[abilityName] = {}
        end
        if not AbilityRangeCheckUnits[abilityName][army] then
            AbilityRangeCheckUnits[abilityName][army] = {}
        end

        AbilityRangeCheckUnits[abilityName][army] = unitIds
        --LOG('*DEBUG: SetAbilityRangeCheckUnits() result = '..repr(AbilityRangeCheckUnits[abilityName][army]))
        return true
    end
    --LOG('*DEBUG: SetAbilityRangeCheckUnits() bad values')
    return false
end

-- internal - MapReticulesToUnitIdsScript
--NomadsIntelOvercharge.lua
UnitCanFireAtPos = function(abilityName, unit, pos)
    local MaxRadius = -1
    local MinRadius = -1

    local bp = unit:GetBlueprint().SpecialAbilities
    if bp and bp[ abilityName ] then
        MaxRadius = bp[ abilityName ].MaxRadius or -1
        MinRadius = bp[ abilityName ].MinRadius or -1
    end

    local upos = unit:GetPosition()
    local dist = VDist2(pos[1], pos[3], upos[1], upos[3])
    if (MaxRadius <= 0 or dist <= MaxRadius) and (MinRadius <= -1 or dist >= MinRadius) then
        return true
    end

    return false
end

-- internal - VerifyScriptCommand
UnitsAreInArmy = function(units, army)
    local ua
    for _, unit in units do
        ua = unit:GetArmy()
        if not army == ua then
            return false, ua
        end
    end
    return true, army
end

--userscriptcommand.lua
function VerifyScriptCommand(data)
-- TODO: cooldown check to see if ability is allowed to be used
    local TaskName = data.TaskName
    local army = GetFocusArmy()
    if TaskName and UnitsAreInArmy(data.Units, army) and LocationIsOk(data, GetAbilityUnitsFromTable(ArmyUnitAbilitiesTable[army], TaskName, false)) then
        data.AuthorizedUnits = data.Units
        data.UserValidated = true
    else
        data.UserValidated = false
    end
    return data
end

-- internal - VerifyScriptCommand
LocationIsOk = function(data, RangeCheckUnits)
    -- almost same script as in worldview.lua
    local InRange, RangeLimited = true, false
    local TaskName = data.TaskName
    local posM = data.Location
    if data.ExtraInfo and data.ExtraInfo.DoRangeCheck then  -- if we do a range check then find that there's a unit in range for the current position
        RangeLimited = true
        InRange = false
        if RangeCheckUnits then
            local unit, maxDist, minDist, posU, dist
            for k, u in RangeCheckUnits do
                unit = GetUnitById(u)
                if unit then
                    maxDist = unit:GetBlueprint().SpecialAbilities[TaskName].MaxRadius
                    minDist = 0  -- TODO: minimum radius distance check currently not implemented
                    if not maxDist or maxDist < 0 then   -- unlimited range
                        InRange = true
                        RangeLimited = false
                        break
                    elseif maxDist == 0 then             -- skip unit
                        continue
                    elseif maxDist > 0 then              -- unit counts towards range check, do check
                        posU = unit:GetPosition()
                        dist = VDist2(posU[1], posU[3], posM[1], posM[3])
                        InRange = (dist >= minDist and dist <= maxDist)
                        if InRange then
                            break
                        end
                    end
                else
                    WARN('*DEBUG: LocationIsOk in tasks.lua couldnt get blueprint for unit. u = '..repr(u)..' unit = '..repr(unit))
                end
            end
        end
    end
    return InRange
end