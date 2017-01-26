local NomadsOrbitalUtils = import('/lua/nomadsorbitalutils.lua')
local Factions = import('/lua/factions.lua').Factions
local AbilityDefinition = import('/lua/abilitydefinition.lua').abilities


local oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {

    OrbitalStrikeCallingCooldownTick = -100,
    OrbitalReinforcementCallingCooldownTick = -100,

    -- ================================================================================================================
    -- TASK SCRIPT SUPPORT
    -- ================================================================================================================

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
            self.SpecialAbilityUnits[type][unitId] = not (canUseAbilityNow == false)
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
        if not self.OrbitalReinforcementReady and self:IsNomadsFaction( self ) then
            StartAbilityCoolDown( self:GetArmyIndex(), 'NomadsAreaReinforcement' )
            local ship = self.NomadsMothership
            local unitType = self:GetSpecialAbilityParam( 'NomadsAreaReinforcement', 'UnitType' ) or AbilityDefinition['NomadsAreaReinforcement']['ExtraInfo']['UnitType'] or 'INA2003'
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
    -- BOOST CAPACITOR
    -- ================================================================================================================

    CapacitorRegisterUnit = function(self, unit)
        -- a unit with the capacitor ability registers itself in the brain. Used so that we can monitor energy surplus 
        -- versus demand and adjust recharge speed for each capacitor unit.
        if unit then
            if unit.OnBrainNotifiesOfChargeFraction then
                --LOG('*DEBUG: CapacitorRegisterUnit Unit registered')

                self.CapNumOfUnits = self.CapNumOfUnits + 1

                -- update values by triggering the unit notification event manually
                local charging = unit:CapIsCharging()
                if charging then
                    self:OnCapacitorUnitChargingState(unit, true)
                end
                self.CapacitorUnits[ unit:GetEntityId() ] = charging
            else
                WARN('Trying to register unit '..repr(unit:GetUnitId())..' at its brain for capacitor ability but it is missing capacitor code.')
            end
        end
        if not self.CapacitorMonitorEconomyThread then
            self.CapacitorMonitorEconomyThread = self:ForkThread( self.CapacitorMonitorEconomy )
        end
    end,

    CapacitorUnregisterUnit = function(self, unit)
        -- Usually used when unit is killed
        if unit then
            --LOG('*DEBUG: CapacitorUnregisterUnit Unit removed')
            table.remove( self.CapacitorUnits, unit:GetEntityId() )
            self.CapNumOfUnits = self.CapNumOfUnits - 1
        end
    end,

    OnCapacitorUnitChargingState = function(self, unit, bool)
        -- unit lets brain know that it wants to charge (bool == true) or doesn't want to charge (bool == false). Adjust energy
        -- variables.
        if unit then
            local unitId = unit:GetEntityId()
            --LOG('OnCapacitorUnitChargingState('..repr(unitId)..', bool = '..repr(bool)..')')
            if self.CapacitorUnits[unitId] ~= nil and self.CapacitorUnits[unitId] ~= bool then
                local energyperTick = self:CapacitorGetUnitEnergyDrainPerTick(unit)
                if bool == true then
                    self.CapacitorUnits[ unit:GetEntityId() ] = true
                    self.CapNumOfUnitsCharging = self.CapNumOfUnitsCharging + 1
                    self.CapEnergyNeeded = self.CapEnergyNeeded + energyperTick
                    unit:OnBrainNotifiesOfChargeFraction( self.CapLastFrac )  -- tell the unit what the last fraction was so it doesn't have to wait for an update (which can take a long time) to start charging
                else
                    self.CapacitorUnits[ unit:GetEntityId() ] = false
                    self.CapNumOfUnitsCharging = self.CapNumOfUnitsCharging - 1
                    self.CapEnergyNeeded = self.CapEnergyNeeded - energyperTick
                end
            end
        end
    end,

    OnCapacitorUnitNewEnergyDrain = function(self, unit, newEnergyDrain)
        -- unit modifies its energy drain parameter for the capacitor ability. We need to adjust the energy variables aswell.
        local oldEnergyperTick = self:CapacitorGetUnitEnergyDrainPerTick(unit)
        local diff = newEnergyDrain - oldEnergyperTick
        self.CapEnergyNeeded = self.CapEnergyNeeded + diff
    end,

    OnCapacitorUnitChecksAutonomousUse = function(self, unit)
        -- unit wants to know if there's energy surpluss so it can to autonomously use the capacitor without affecting
        -- recharge rates of other units.
        -- TODO: this can be a bit smarter, like checking if we still have enough energy when this unit starts to charge its
        -- capacitor.
        return self:CapacitorIsEconomyOk()
    end,

    CapacitorNotifyUnitsOfChargeFraction = function(self, fraction)
        -- we've decided of a new charge fraction. Notify all charging units so they can adjust their recharge rates.
        local unit
        for uid, charging in self.CapacitorUnits do
            if charging then
                unit = GetUnitById(uid)
                if unit then
                    unit:OnBrainNotifiesOfChargeFraction( fraction )
                end
            end
        end
    end,

    CapacitorNotifyUnitsOfEnergyState = function(self, sufficient)
        -- There's no energy surplus. Notify all units so they might start their dissipation scripting.
        --LOG('*DEBUG: CapacitorNotifyUnitsOfEnergyState('..repr(sufficient)..')')
        local unit
        for uid, charging in self.CapacitorUnits do
            unit = GetUnitById(uid)
            if not unit then
                continue
            elseif sufficient then
                unit:OnBrainNotifiesOfSufficientEnergy()
            else
                unit:OnBrainNotifiesOfInsufficientEnergy()
            end
        end
    end,

    CapacitorIsEconomyOk = function(self)
        return self.CapEconIsOk
    end,

    CapacitorMonitorEconomy = function(self)
        -- continuesly monitors the economy, calculates a charge fraction and notifies units when important events happen.
        --LOG('*DEBUG: CapacitorMonitorEconomy()')
        WaitTicks(1)
        local lastEconOk, curNetIncome, curStorageRatio, frac = true, false, 0, 0, 0

        while self and not ArmyIsOutOfGame(self:GetArmyIndex()) do

            curStorageRatio = self:GetArmyStat("Economy_Ratio_Energy", 0.0).Value or 0
            self.CapEconIsOk = (curStorageRatio >= 1 and curStorageRatio < 1.1)
            frac = 0

            -- notify units of current economy state
            if self.CapEconIsOk ~= lastEconOk then
                self:CapacitorNotifyUnitsOfEnergyState(self.CapEconIsOk)
            end
            lastEconOk = self.CapEconIsOk

            -- determine the cap charge fraction of this tick
            if self.CapEconIsOk then
                if self.CapEnergyNeeded > 0 then
                    curNetIncome = (self:GetArmyStat("Economy_Income_Energy", 0.0).Value - self:GetArmyStat("Economy_Output_Energy", 0.0).Value)
                    if curNetIncome > 0 then
                        frac = math.min( 1, curNetIncome / self.CapEnergyNeeded )
                    end
                end
            end

            -- notify units of current fraction
            if frac ~= self.CapLastFrac then
                self:CapacitorNotifyUnitsOfChargeFraction( frac )
            end
            self.CapLastFrac = frac

            --LOG('*DEBUG: curNetIncome = '..repr(curNetIncome)..' curStorageRatio = '..repr(curStorageRatio)..' self.CapEnergyNeeded = '..repr(self.CapEnergyNeeded)..' frac = '..repr(frac))
            if curStorageRatio < 0.75 then
                WaitSeconds(5)
            elseif curStorageRatio < 0.9 then
                WaitSeconds(1)
            elseif frac == 0 then  -- when low on energy reduce monitor frequency, for better game performance
                WaitTicks(4)
            end
            WaitTicks(1)
        end

        self.CapacitorMonitorEconomyThread = nil
    end,

    CapacitorGetUnitEnergyDrainPerTick = function(self, unit)
        return unit:CapGetEnergyDrainPerSecond() / 10
    end,

    -- ================================================================================================================
    -- NOMADS ORBITAL UNIT CONSTRUCTION
    -- ================================================================================================================

    RequestUnitAssignedToParent = function(self, requester, bpId, AssignedCallback)
        -- AssignedCallback => function(parent, requestedUnit)

        -- using lower case blueprint id's cause that's what we get if we do   unit:GetBlueprint().BlueprintId
        bpId = string.lower( bpId )

        -- make sure the tables exist. Do it here so no tables are created for brains that don't need them.
        if not self.RequestUnitQueue then
            self.RequestUnitQueue = {}        -- { [bpId] => { requester = <unit>, callback = <function>, }, }
            self.RequestedUnitPool = {}       -- { [bpId] => { [UnitEntityId] => [ParentEntityid], }, }
        end

        -- add the requester + callback to a database so we can use it later on, when we have a unit
        if not self.RequestUnitQueue[bpId] then
            self.RequestUnitQueue[bpId] = {}
        end
        table.insert( self.RequestUnitQueue[bpId], { requester = requester, callback = AssignedCallback or false } )

        -- find a free unit for the requester, if there is any
        local unit = false
        if self.RequestedUnitPool[ bpId ] then

            -- check if there is unit if the given type currently unassigned use that one instead. Since we're going through the table
            -- anyway look for entries to delete.
            local dist = 9999999
            local pos = requester:GetPosition()
            local remove = {}

            for entityId, parent in self.RequestedUnitPool[ bpId ] do
                if not parent then
                    local u = GetUnitById( entityId )
                    if u and not u:BeenDestroyed() and not u:IsDead() then
                        -- trying to get the nearest unit
                        local uPos = u:GetPosition()
                        local d = VDist2( uPos[1], uPos[3], pos[1], pos[3] )
                        if d < dist then
                            dist = d
                            unit = u
                            break
                        end
                    else
                        -- put the current entry up for removal
                        table.insert( remove, unit )
                    end
                end
            end

            -- delete any invalid entries found
            if table.getn( remove ) > 0 then
                for k, v in remove do
                    self.RequestedUnitPool[bpId][v] = nil
                    table.remove( self.ArtilleryUnitAssignments, v )
                end
            end
        end

        -- if we found a free unit give it a new parent
        if unit then
            self:AssignUnitToParent(unit, requester)

        -- no unused unit found. we'll create a new one.
        else
            local cb = function(self)
                self:GetAIBrain():AssignUnitToParent( self, false )    -- 'self' in this case is the newly created unit
            end
            self:ConstructUnitInOrbit( bpId, cb )
        end
    end,

    AssignUnitToParent = function(self, unit, parent)
        -- assign a unit to a parent. If parent is not passed get the first in the list of requesters.

        local bpId = unit:GetBlueprint().BlueprintId
        local callback, queueKey

        -- fill in the missing variables: callback, queueKey and parent (if applicable)
        if parent then
            -- find the callback and queue key
            for k, v in self.RequestUnitQueue[bpId] do
                if v.requester == parent then
                    queueKey = k
                    callback = v.callback
                    break
                end
            end
        else
            -- using table.keys as the easiest method to get the first key. When we have it we can determine parent and callback
            queueKey = table.keys( self.RequestUnitQueue[bpId] )[1]
            parent = self.RequestUnitQueue[bpId][queueKey].requester
            callback = self.RequestUnitQueue[bpId][queueKey].callback
        end

        -- remove requester from requesters table so we don't assign another unit to the requester
        self.RequestUnitQueue[bpId][queueKey] = nil
        table.removeByValue(self.RequestUnitQueue[bpId], queueKey)

        -- add the unit to the pool of requested units, for possible future reference
        local unitEntityId = unit:GetEntityId()
        local parentEntityId = parent:GetEntityId()
        if not self.RequestedUnitPool[bpId] then self.RequestedUnitPool[bpId] = {} end
        self.RequestedUnitPool[bpId][unitEntityId] = parentEntityId

        -- do the callback
        if callback then
            local thread = ForkThread( callback, parent, unit )
            self.Trash:Add(thread)
        end
    end,

    ParentOfUnitKilled = function(self, unit)
        -- when the parent dies the child is orphaned and might be assigned to another parent when it's available.
        local bpId = unit:GetBlueprint().BlueprintId
        local unitEntityId = unit:GetEntityId()
        self.RequestedUnitPool[bpId][unitEntityId] = false
    end,

    RemoveRequesterUnitFromPool = function(self, unit)
        -- should call this whenever a requested unit is removed from the pool. This could happen when the unit is destroyed or, for
        -- example, used in case of the Nomads SCU and the SCU head.
        local bpId = unit:GetBlueprint().BlueprintId
        local unitEntityId = unit:GetEntityId()
        self.RequestedUnitPool[bpId][unitEntityId] = nil
        table.remove( self.RequestedUnitPool[bpId], unitEntityId )
    end,

    ConstructUnitInOrbit = function(self, bpId, ConstructedCallback)
        -- Tells the Nomads orbital unit to construct a unit of given type. Only these units can be constructed in orbit:
        if bpId ~= 'ino2302' and bpId ~= 'inu3006h' then
            WARN('Cant construct unit type '..repr(bpId)..' in orbit.')
            return false
        end
        local ship = self.NomadsMothership
        return ship:AddToConstructionQueue( bpId, ConstructedCallback ) or true
    end,

    KillAllRequestedUnits = function(self)
        if self.RequestedUnitPool then
            for bpId, v in self.RequestedUnitPool do
                for unitEntityId, parentEntityId in v do
                    local unit = GetUnitById( unitEntityId )
                    if unit and not unit:BeenDestroyed() and not unit:IsDead() then
                        unit:Kill()
                    end
                end
            end
        end
    end,

    -- ================================================================================================================

    CreateOrbitalUnit = function(self)
        --LOG('*DEBUG: Creating orbital unit')
        local bp = 'INO0001'
        local army = self:GetArmyIndex()
        local x, z = self:GetArmyStartPos()
        local y = 0 -- TODO: use surface instead
        self.NomadsMothership = CreateUnitHPR( bp, army, x, y, z, 0, 0, 0)
        return self.NomadsMothership
    end,

    RemoveOrbitalUnit = function(self)
        local fn = function(self)
            --LOG('*DEBUG: removing orbital unit in 10 seconds')
            WaitSeconds(10)
            if self.NomadsMothership then
                self.NomadsMothership:Destroy()
            end
        end
        ForkThread( fn, self )
    end,

    OrbitalStrikeTarget = function(self, targetPosition)
        if self.NomadsMothership then
            self.NomadsMothership:OnGivenNewTarget(targetPosition)
        end
    end,

    IsNomadsFaction = function(self)
        -- Says true if we're Nomads, false otherwise
        local factionIndex = self:GetFactionIndex()
        return ( Factions[factionIndex].Category == 'NOMADS' )
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

        -- if we're nomads create a mothership
        local army = self:GetArmyIndex()
        if self:IsNomadsFaction() and not ArmyIsCivilian(army) and not ArmyIsOutOfGame(army) then
            self:CreateOrbitalUnit( self )
        end
    end,

    OnDefeat = function(self)
        self:RemoveOrbitalUnit()
        self:KillAllRequestedUnits()
        oldAIBrain.OnDefeat(self)
    end,

    OnVictory = function(self)
        oldAIBrain.OnVictory(self)
    end,

    OnDraw = function(self)
        oldAIBrain.OnDraw(self)
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