local Factions = import('/lua/factions.lua').Factions
local AbilityDefinition = import('/lua/abilitydefinition.lua').abilities
local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat


local oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {

    OrbitalStrikeCallingCooldownTick = -100,
    OrbitalReinforcementCallingCooldownTick = -100,

    -- ================================================================================================================
    -- TASK SCRIPT SUPPORT
    -- ================================================================================================================
    
    --[[
    --list of the abilities that the army brain has. parameters for each ability. If the ability is available to activate immediately.
    --example structure:
    BrainSpecialAbilities = {
        AreaBombardment = { --AbilityType
            AvailableNow = false,
            NumberOfReticules = 1,
            RangeCheckRequired = true,
        },
    },
    
    --list of units that have abilities. list of abilities of each unit. parameters for each ability. if the ability is available to activate immediately.
    
    --example structure:
    UnitSpecialAbilities = {
        1 = { --unitID
            AreaBombardment = { --AbilityType
                AvailableNowUnit = 0,
                AreaOfEffect = 1,
                RangeCheckUnitRequired = true,
            },
        },
    },
    
    --how to loop through the units list per ability
    for unitID,abilityTypes in UnitSpecialAbilities do
        if abilityTypes[abilityName] and abilityTypes[abilityName][parameter] == false then
            abilityTypes[abilityName][parameter] = true
        end
    end
    
    --]]
    
    
    
    --abilities get added, removed, changed
    SetSpecialAbility = function(self, abilityName, data)
        if data == 'Remove' and self.BrainSpecialAbilities[abilityName] then
            self.BrainSpecialAbilities[abilityName] = nil
        elseif type(data) == 'table' then
            if not self.BrainSpecialAbilities[abilityName] then
                self.BrainSpecialAbilities[abilityName] = data
            else
                for key,value in data do
                    self.BrainSpecialAbilities[abilityName][key] = value
                end
            end
        else
            WARN('Nomads: SetSpecialAbility: Attempt to set special brain ability '..repr(abilityName)..' with malformed data! | data =  ('..repr(data)..')')
        end
        
        self.QueueAbilityPanelUpdate = true
    end,
    
    --units update themselves in the list when they gain, change or lose abilities
    --brain:SetUnitSpecialAbility(self, 'OrbitalBombardment', {AvailableNowUnit = 1,})
    SetUnitSpecialAbility = function(self, unit, abilityName, data)
        local unitId = unit:GetEntityId()
        --replace unit argument with unitId argument?
        if data == 'Remove' then
            if self.UnitSpecialAbilities[unitId][abilityName] then
                self.UnitSpecialAbilities[unitId][abilityName] = nil
            else
                SPEW('Nomads: SetUnitSpecialAbility: Attempt to remove non existent special ability '..repr(abilityName)..' from unit ['..repr(unit:GetUnitId())..']')
            end
        elseif type(data) == 'table' then
            if not self.UnitSpecialAbilities[unitId] then
                self.UnitSpecialAbilities[unitId] = {}
            end
            if not self.UnitSpecialAbilities[unitId][abilityName] then
                self.UnitSpecialAbilities[unitId][abilityName] = {}
            end
            
            self.UnitSpecialAbilities[unitId][abilityName] = table.merged(self.UnitSpecialAbilities[unitId][abilityName], data)
        else
            WARN('Nomads: SetUnitSpecialAbility: Attempt to set special ability '..repr(abilityName)..' on unit ['..repr(unit:GetUnitId())..'] with malformed data! | data =  ('..repr(data)..')')
        end
        
        self.QueueAbilityPanelUpdate = true
    end,
    
    --this ensures we only update the panel at most once per tick. No need to spam this late game.
    AbilityPanelUpdateThread = function(self)
        local army = self:GetArmyIndex()
        while not self:IsDefeated() do
            WaitTicks(1)
            if self.QueueAbilityPanelUpdate then
                self:CheckAbilities()
                UpdateSpecialAbilityUI(army, self.BrainSpecialAbilities, self.UnitSpecialAbilities)
                self.QueueAbilityPanelUpdate = false
            end
        end
    end,
    
    --units register abilities when they are built, and deregister them when they die.
    --when units are destroyed, their abilities are deregistered.
    --upgrades register and deregister special abilities for units.
    --weapons, timers and more set whether abilities can be activated immediately.
    
    --when the unit list is updates, the abilities are updated too.
    --when abilities are updated, the UI gets notified.
    
    --The ui is notified and arranges ability buttons on the panel as per the abilities list.
    --It adds, removes, enables, disables the ability buttons.
    
    --when pressed, the ability buttons issue a run the script for that ability.
    --if a script operates on units, having units selected will cause the script to run only on the selection and not the whole army.
    --these script orders then go through many checks to make sure they work properly.
    --These scripts give any orders needed, and then notify the abilities panel.
    
    --this makes sure that the abilities table matches the units, both in listed and currently available abilities.
    CheckAbilities = function(self)
        --add any missing abilities
        --remove any unused abilities
        
        --set each ability as useable if there is a unit that can use it right now.
        
        --we loop through the whole queue to make sure we dont miss anything, and check for multiple things so we stuff this table here with our results.
        local AbilityUpdateQueue = {}
        
        for unitID, abilityTypes in self.UnitSpecialAbilities do
            local unit = GetEntityById(unitID)
            if not unit or unit:BeenDestroyed() then
                self.UnitSpecialAbilities[unitID] = nil
                continue
            end
            for AbilityName, Ability in abilityTypes do
                --discount disabled abilities. if all units have it disabled, the ability disappears from the panel.
                if Ability.Enabled == false then continue end
                if not AbilityUpdateQueue[AbilityName] then
                    AbilityUpdateQueue[AbilityName] = 0
                end
                if Ability.AvailableNowUnit > 0 then
                    --right now we only support true/false but we might as well count them since we need to loop through everything anyway
                    --also this means that adding in a UI counter for the number of units that can activate an ability at any time becomes trivial!
                    AbilityUpdateQueue[AbilityName] = AbilityUpdateQueue[AbilityName] + 1
                end
            end
        end
        
        --update and remove abilities from the brain table
        for Ability, AbilityData in self.BrainSpecialAbilities do
            if AbilityUpdateQueue[Ability] then
                --self.BrainSpecialAbilities[Ability]['AvailableNow'] = AbilityUpdateQueue[Ability]
                AbilityData['AvailableNow'] = AbilityUpdateQueue[Ability]
                AbilityUpdateQueue[Ability] = nil --remove the entry from the table
            else --optional: add a flag for having unit-less abilities? elseif not AbilityUpdateQueue[Ability]['UnitUnrestricted'] then
                --remove the ability since no units support it
                self.BrainSpecialAbilities[Ability] = nil
            end
        end
        
        --add in any missing abilities.
        for Ability, AvailableCount in AbilityUpdateQueue do
            if not self.BrainSpecialAbilities[Ability] then
                self.BrainSpecialAbilities[Ability] = {}
            end
            --TODO: add in any missing parameters using the default abilities tables. or perhaps not.
            self.BrainSpecialAbilities[Ability]['AvailableNow'] = AvailableCount
        end
    end,


    --TODO: refactor these away, they arent used as part of the new abilities code.
    SpecialAbilities = {},
    SpecialAbilityUnits = {},
    SpecialAbilityRangeCheckUnits = {},

    GetSpecialAbilityUnits = function(self, type)
        local units = {}
        if self.SpecialAbilityUnits[type] then
            local remove = {}

            -- compile list of units in this type of special ability
            for uid, available in self.SpecialAbilityUnits[type] do
                local unit = GetEntityById(uid)
                if unit and not unit:BeenDestroyed() then
                    table.insert( units, unit )
                else
                    table.insert( remove, uid )
                end
            end

            -- remove bad entries from the table so we won't get them next time
            for k, uid in remove do
                self.SpecialAbilityUnits[type][uid] = nil
            end
        end
        return units
    end,

    GetSpecialAbilityRangeCheckUnits = function(self, type)
        local units = {}
        if self.SpecialAbilityRangeCheckUnits[type] then
            local remove = {}

            -- compile list of units in this type of special ability
            for k, v in self.SpecialAbilityRangeCheckUnits[type] do
                local unit = GetEntityById(v)
                if unit and not unit:BeenDestroyed() then
                    table.insert( units, unit )
                else
                    table.insert( remove, v )
                end
            end

            -- remove bad entries from the table so we won't get them next time
            for k, v in remove do
                table.removeByValue( self.SpecialAbilityRangeCheckUnits[type], v )
            end
        end
        return units
    end,

    GetSpecialAbilityParam = function(self, type, param1, param2)
        local r
        if type and param1 and self.SpecialAbilities[ type ][ param1 ] then
            if param2 and self.SpecialAbilities[ type ][ param1 ][ param2 ] then
                r = self.SpecialAbilities[ type ][ param1 ][ param2 ]
            else
                r = self.SpecialAbilities[ type ][ param1 ]
            end
        end
        return r
    end,

    -- ================================================================================================================

    CreateBrainShared = function(self, planName)
        self.RequestedUnitPool = {}
        self.SpecialAbilities = {}
        self.SpecialAbilityUnits = {}
        self.CapacitorUnits = {}
        self.CapNumOfUnits = 0
        self.CapNumOfUnitsCharging = 0
        self.CapEnergyNeeded = 0
        self.CapLastFrac = -1
        self.CapEconIsOk = true
        
        self.BrainSpecialAbilities = {}
        self.UnitSpecialAbilities = {}

        oldAIBrain.CreateBrainShared(self, planName)

        self:ForkThread(self.AbilityPanelUpdateThread)
        self:LoadCustomFactions()
    end,

    OnSpawnPreBuiltUnits = function(self)
        -- Spawns Nomads prebuilt units
        oldAIBrain.OnSpawnPreBuiltUnits(self)

        local factionIndex = self:GetFactionIndex()
        if self.PreBuilt and Factions[factionIndex].Category ~= 'UEF' and Factions[factionIndex].Category ~= 'AEON'
                      and Factions[factionIndex].Category ~= 'CYBRAN' and Factions[factionIndex].Category ~= 'SERAPHIM' then

            local posX, posY = self:GetArmyStartPos()

            local resourceStructures = Factions[factionIndex].PreBuildUnits.MassExtractors or {}
            for k, v in resourceStructures do
                local unit = self:CreateResourceBuildingNearest(v, posX, posY)
                if unit ~= nil and unit:GetBlueprint().Physics.FlattenSkirt then
                    unit:CreateTarmac(true, true, true, false, false)
                end
            end

            local initialUnits = Factions[factionIndex].PreBuildUnits.Regular or {}
            for k, v in initialUnits do
                local unit = self:CreateUnitNearSpot(v, posX, posY)
                if unit ~= nil and unit:GetBlueprint().Physics.FlattenSkirt then
                    unit:CreateTarmac(true, true, true, false, false)
                end
            end
        end
    end,

    -- ================================================================================================================

    LoadCustomFactions = function(self)
        self.CustomFactions = {}
        for k, v in Factions do
            if v.Key ~= 'uef' and v.Key ~= 'aeon' and v.Key ~= 'cybran' and v.Key ~= 'seraphim' then
                table.insert( self.CustomFactions, { customCat = ParseEntityCategory(v.Category), cat = v.PlatoonTemplateKey, } )
            end
        end
    end,
}
