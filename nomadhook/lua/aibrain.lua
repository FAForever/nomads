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
    --TODO: refactor this, at least so its self.SpecialAbilityUnits[unitId][abilityType] instead of self.SpecialAbilityUnits[type][unitId]


    SpecialAbilities = {},
    SpecialAbilityUnits = {},
    SpecialAbilityRangeCheckUnits = {},

    AddSpecialAbilityUnit = function(self, unit, type, autoEnable, canUseAbilityNow)
        local unitId = unit:GetEntityId()
        if AbilityDefinition[ type ] then
            if not self.SpecialAbilityUnits[type] then
                self.SpecialAbilityUnits[type] = {}
            end
            self.SpecialAbilityUnits[type][unitId] = not (canUseAbilityNow == false)
            SetAbilityUnits( self:GetArmyIndex(), type, self:GetSpecialAbilityUnitIds(type) )
            if autoEnable and table.getsize( self.SpecialAbilityUnits[type] ) == 1 then
                self:EnableSpecialAbility( type, true )
            end
        end
    end,

    SetSpecialAbilityUnitAvailability = function(self, unit, type, canUseAbilityNow)
        local unitId = unit:GetEntityId()
        if AbilityDefinition[ type ] then
            if not self.SpecialAbilityUnits[type] then
                self.SpecialAbilityUnits[type] = {}
            end
            self.SpecialAbilityUnits[type][unitId] = (canUseAbilityNow == true)
            SetAbilityUnits( self:GetArmyIndex(), type, self:GetSpecialAbilityUnitIds(type) )
        end
    end,

    RemoveSpecialAbilityUnit = function(self, unit, type, autoDisable)
        if self.SpecialAbilityUnits[type] then
            local unitId = unit:GetEntityId()
            self.SpecialAbilityUnits[type][unitId] = nil
            SetAbilityUnits( self:GetArmyIndex(), type, self:GetSpecialAbilityUnitIds(type) )
            if autoDisable and table.getsize( self.SpecialAbilityUnits[type] ) < 1 then
                self:EnableSpecialAbility( type, false )
            end
        end
    end,

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

    AddSpecialAbilityRangeCheckUnit = function(self, unit, type)
        local unitId = unit:GetEntityId()
        if AbilityDefinition[ type ] then
            if not self.SpecialAbilityRangeCheckUnits[type] then
                self.SpecialAbilityRangeCheckUnits[type] = {}
            end
            table.insert( self.SpecialAbilityRangeCheckUnits[type], unitId )
            SetAbilityRangeCheckUnits( self:GetArmyIndex(), type, self:GetSpecialAbilityRangeCheckUnitIds(type) )
        end
    end,

    RemoveSpecialAbilityRangeCheckUnit = function(self, unit, type)
        if self.SpecialAbilityRangeCheckUnits[type] then
            local unitId = unit:GetEntityId()
            table.removeByValue( self.SpecialAbilityRangeCheckUnits[type], unitId )
            SetAbilityRangeCheckUnits( self:GetArmyIndex(), type, self:GetSpecialAbilityRangeCheckUnitIds(type) )
        end
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

    GetSpecialAbilityUnitIds = function(self, type)
        self:GetSpecialAbilityUnits(type)  -- only for cleaning up the table, not interested in the results of this call
        return self.SpecialAbilityUnits[type]
    end,

    GetSpecialAbilityRangeCheckUnitIds = function(self, type)
        self:GetSpecialAbilityRangeCheckUnits(type)  -- only for cleaning up the table, not interested in the results of this call
        return self.SpecialAbilityRangeCheckUnits[type]
    end,

    EnableSpecialAbility = function(self, type, enable)
        --LOG('*DEBUG: EnableSpecialAbility type = '..repr(type))
        if AbilityDefinition[type].enabled == false then
            --WARN('Ability "'..repr(type)..'" is disabled in abilitydefinition file')
            return false
        else
            if not self.SpecialAbilities[ type ] then
                self.SpecialAbilities[ type ] = {}
                if AbilityDefinition[type]['ExtraInfo'] then
                    for k, v in AbilityDefinition[type]['ExtraInfo'] do
                        self:SetSpecialAbilityParam( type, k, v )
                    end
                end
            end
            enable = (enable == true)
            if self:IsSpecialAbilityEnabled( type ) == nil or self:IsSpecialAbilityEnabled( type ) ~= enable then
                local army = self:GetArmyIndex()
                self.SpecialAbilities[ type ][ 'enabled' ] = enable
                if enable then
                    AddSpecialAbility( army, type )
                else
                    RemoveSpecialAbility( army, type )
                end
            end
        end
    end,

    IsSpecialAbilityEnabled = function(self, type)
         if self.SpecialAbilities[ type ] then
             return self.SpecialAbilities[ type ][ 'enabled' ]
         end
    end,

    SetSpecialAbilityParam = function(self, type, parameter, value)

        -- set and/or change a parameter for the special ability. Returns old value (could be nil if previously not set)
        if parameter ~= 'enabled' then
            local old
            if self.SpecialAbilities[ type ][ parameter ] then
                old = self.SpecialAbilities[ type ][ parameter ]
            end
            self.SpecialAbilities[ type ][ parameter ] = value
            return old
        else
            WARN('AIBrain: SetSpecialAbilityParam(): cant set parameter "'..parameter..'" this way!')
        end
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
    -- ORBITAL REINFORCEMENT
    -- ================================================================================================================

    OrbitalReinforcementReady = false,

    PrepareOrbitalReinforcement = function(self)
        -- has the ship construct a reinforcement unit which can then be used with the special ability.
        if not self.OrbitalReinforcementReady and Factions[self:GetFactionIndex()].Category == 'NOMADS' then
            StartAbilityCoolDown( self:GetArmyIndex(), 'NomadsAreaReinforcement' )
            local ship = self.NomadsMothership
            local unitType = self:GetSpecialAbilityParam( 'NomadsAreaReinforcement', 'UnitType' ) or AbilityDefinition['NomadsAreaReinforcement']['ExtraInfo']['UnitType'] or 'xna0203'
            local readyFn = function(self)      -- self is the constructed unit, not the brain
                local brain = self:GetAIBrain()
                brain:AddSpecialAbilityUnit( self, 'NomadsAreaReinforcement', false )
                brain:SetOrbitalReinforcementReady(true)
            end
            ship:AddToConstructionQueue( unitType, readyFn )
        else
            DisableSpecialAbility( 'NomadsAreaReinforcement' )
        end
    end,

    SetOrbitalReinforcementReady = function(self, ready)
        self.OrbitalReinforcementReady = (ready == true)
        if self.OrbitalReinforcementReady then
            EnableSpecialAbility( 'NomadsAreaReinforcement' )
        else
            DisableSpecialAbility( 'NomadsAreaReinforcement' )
        end
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

        oldAIBrain.CreateBrainShared(self, planName)

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
