do

RandomFloat = import('/lua/utilities.lua').GetRandomFloat
GetTrueEnemyUnitsInCylinder = import('/lua/utilities.lua').GetTrueEnemyUnitsInCylinder


-------- GENERIC UNIT BEHAVIORS --------
-- (for units build at factories)

GenericPlatoonBehaviors = function(platoon)
    -- A generic function that is called for each unit that the AI constructs. Useful to add generic behavior for all units.
    --LOG('*DEBUG: AI GenericPlatoonBehaviors')
    for k,v in platoon:GetPlatoonUnits() do
        if not v.Dead then
            -- Capacitor behavior
            if not v.CapacitorToggleThread then
                v.CapacitorToggleThread = v:ForkThread( CapacitorToggleThread )
            end
        end
    end
end

function CapacitorToggleThread(unit)
    -- AI support for capacitor
    if not unit.HasCapacitorAbility then
        return
    end

    local healthFrac = 0
    local TECH1
    while not unit.Dead do
        -- Wait till we have a full capacitor and not occupied
        while not unit.Dead and (not (unit.Sync.CapacitorState == 'Filled') or unit:IsUnitState('Busy') or unit:IsUnitState('Attached')) do
            if not unit.Sync.AutoCapacitor and unit:HasEnhancement('Capacitor') then
                unit:SetAutoCapacitor(true)
            end
            WaitSeconds(10)
        end
        local numWep = unit:GetWeaponCount()

        -- wait till we're not idling or till sustained some damage
        healthFrac = ( unit:GetHealth() / unit:GetMaxHealth() )
        if healthFrac < 0.8 then
            unit.CapacitorSwitchStates[unit.Sync.CapacitorState](unit)
        -- or wait till we're doing engineering work (except reclaiming which doesn't need a boost)
        elseif unit:IsUnitState('Building') or unit:IsUnitState('Repairing') or unit:IsUnitState('Capturing') then
            TECH1 = EntityCategoryContains(categories.TECH1, unit.UnitBeingBuilt)
            if (TECH1 and unit:GetWorkProgress() <= 0.25) or (not TECH1 and unit:GetWorkProgress() <= 0.65) then
                unit.CapacitorSwitchStates[unit.Sync.CapacitorState](unit)
            end
        -- or wait until we are getting an upgrade
        elseif unit:IsUnitState('Enhancing') and unit:GetWorkProgress() < 0.7 then
            unit.CapacitorSwitchStates[unit.Sync.CapacitorState](unit)

        -- or check number nearby friendlies versus enemies
        elseif numWep > 0 then

            -- determine what can I shoot and what is my range?
            local position = unit:GetPosition()
            local targetUnits = 0
            local WeaponRangesByLayer = {}
            
            for w=1, numWep do
                local wep = unit:GetWeapon(w)
                if wep.IsEnabled then
                    wbp = wep:GetBlueprint()
                    curLayer = unit:GetCurrentLayer()
                    if not wbp.FireTargetLayerCapsTable[curLayer] then
                        continue
                    end
                    
                    --parse the layer caps into a table so we can loop through them.
                    local layersToShootAt = {}
                    string.gsub(wbp.FireTargetLayerCapsTable[curLayer], "%a+", function(w) table.insert(layersToShootAt, w) end)
                    
                    --find the largest ranges we can find targets at for each layer
                    for k,layer in layersToShootAt do
                        WeaponRangesByLayer[layer] = math.max( WeaponRangesByLayer[layer] or 0, wbp.MaxRadius )
                    end
                end
            end
            
            for layer,range in WeaponRangesByLayer do
                local enemyUnits = GetTrueEnemyUnitsInCylinder(unit, position, range) or {}
                for k,target in enemyUnits do
                    local targetLayer = target:GetCurrentLayer()
                    --check if we have a weapon capable of firing at the target unit
                    if WeaponRangesByLayer[targetLayer] then
                        targetUnits = targetUnits + 1
                    end
                    -- decide to activate capacitor or not. no need to check further if we already meet our criteria.
                    if targetUnits >= 4 then
                        unit.CapacitorSwitchStates[unit.Sync.CapacitorState](unit)
                        break
                    end
                end
            end
        end
        WaitSeconds(5)
    end
end

function BehemothCrushBehavior(self)
    -- Pretty much same as BehemothBehavior expect that this behavior makes the unit move up to the target instead of attacking from afar.
    -- Meant for experimentals that crush units such as Nomads hover experimentals.

    AssignExperimentalPriorities(self)

    local experimental = GetExperimentalUnit(self)
    local targetUnit = false
    local lastBase = false
    local airUnit = EntityCategoryContains(categories.AIR, experimental)

    --Find target loop
    while experimental and not experimental.Dead do
        if lastBase then
            targetUnit, lastBase = WreckBase(self, lastBase)
        end
        if not lastBase then
            targetUnit, lastBase = FindExperimentalTarget(self)
        end

        while not experimental.Dead and not experimental:IsIdleState() do

            local nearCommander = CommanderOverrideCheck(self)
            if nearCommander and nearCommander ~= targetUnit then
                targetUnit = nearCommander
            end

            if targetUnit then
                IssueClearCommands({experimental})
                IssueMove({experimental}, targetUnit:GetPosition() )
            end

            WaitSeconds(1)
        end

        WaitSeconds(1)
    end
end


-------- NOMADS EXPERIMENTAL BEHAVIORS --------

function CometBehavior(self)
    BehemothBehavior(self)
end

function BeamerBehavior(self)
    BehemothBehavior(self)
end

function CrawlerBehavior(self)
    BehemothCrushBehavior(self)
end

function BullfrogBehavior(self)
    BehemothCrushBehavior(self)
end


function CometTryExpGhettoGunship(self)
    -- Make the Comet pick up Beamers to form a ghetto gunship

    local unit = GetExperimentalUnit(self)

    if unit:GetUnitId() ~= 'xna0401' then
        return
    end

    --LOG('*DEBUG: AI starting CometTryExpGhettoGunship for unit '..repr(unit:GetUnitId()))

    local BeamerCat = ParseEntityCategory( 'xnl0402' )  -- this unit can be used to form exp ghetto gunship
    local BeamerFindRadius = 30
    local brain = unit:GetAIBrain()
    local army = unit:GetArmy()
    local cargo, ExpInCargo, HasCargo, healthFrac, pos, beamer

    -- if we dont have a beamer attached then keep scanning the area to find one. If so, pick it up
    while not unit.Dead do

        ExpInCargo = false
        HasCargo = false
        cargo = self:GetCargo()
        if cargo and table.getn(cargo) > 0 then   -- check for exp in cargo. No need to pick up a second one
            HasCargo = true
            for _,v in cargo do
                if not v.Dead and EntityCategoryContains(categories.EXPERIMENTAL, v) then
                    ExpInCargo = true
                    break
                end
            end
        end

        healthFrac = ( unit:GetHealth() / unit:GetMaxHealth() )
        if HasCargo and healthFrac <= 0.2 then
            -- cargo and low on health => drop units asap!
            LOG('*DEBUG: AI comet emergency cargo drop')
            pos = unit:GetPosition()
            unit:IssueClearCommands()
            unit:IssueTransportUnload( cargo, pos )
            unit:IssueMove( AIUtils.AIGetStartLocations(brain)[army] )

        elseif not ExpInCargo and healthFrac >= 0.35 then
            -- no exp in cargo: find beamer
            beamer = false
            pos = unit:GetPosition()
--            beamers = brain:GetUnitsAroundPoint( BeamerCat, pos, BeamerFindRadius, 'Ally' )
            beamers = AIUtils.GetOwnUnitsAroundPoint( brain, BeamerCat, pos, BeamerFindRadius )
            for k, b in beamers do
                if not b:BeenDestroyed() and not b.Dead and b:GetFractionComplete() >= 1 then
                    beamer = b
                    break
                end
            end
            if beamer then
                LOG('*DEBUG: AI comet trying to pick up beamer')
                unit:IssueClearCommands()
                unit:IssueTransportLoad( {beamer} , pos )
            end
        end

        WaitSeconds(5)
    end
end



-------- NOMADS ACU BEHAVIOR --------

local oldCommanderBehavior = CommanderBehavior

function CommanderBehavior(platoon)
    --LOG('*DEBUG: CommanderBehavior')
    for k,v in platoon:GetPlatoonUnits() do
        if not v.Dead and not v.AIOrbitalBombardmentThread then
            v.AIOrbitalBombardmentThread = v:ForkThread( OrbitalBombardmentThread, platoon )
        end
        if not v.Dead and not v.AIIntelProbeThread then
            v.AIIntelProbeThread = v:ForkThread( CommanderIntelProbeThread, platoon )
        end
    end
    oldCommanderBehavior(platoon)
end

if rawget(import('/lua/AI/AIBehaviors.lua'), 'CommanderThreadSorian') then  -- Checking for Sorian to prevent game crash
    local oldCommanderThreadSorian = CommanderThreadSorian
    function CommanderThreadSorian(cdr, platoon)
        --LOG('*DEBUG: CommanderThreadSorian')
        for k,v in platoon:GetPlatoonUnits() do
            if not v.Dead and not v.AIOrbitalBombardmentThread then
                v.AIOrbitalBombardmentThread = v:ForkThread( OrbitalBombardmentThreadSorian, platoon )
            end
            if not v.Dead and not v.AIIntelProbeThread then
                v.AIIntelProbeThread = v:ForkThread( CommanderIntelProbeThreadSorian, platoon )
            end
        end
        oldCommanderThreadSorian(cdr, platoon)
    end
end

CommanderBombardPriorityList = {
    (categories.EXPERIMENTAL * categories.STRUCTURE),
    (categories.ARTILLERY - categories.TECH1),
    (categories.MASSEXTRACTION * categories.STRUCTURE),
    (categories.ANTIMISSILE - categories.MOBILE),
    (categories.STRUCTURE - categories.WALL),
    (categories.ALLUNITS - categories.WALL),
}

function OrbitalBombardmentThread(cdr, platoon)
    if cdr:GetUnitId() ~= 'xnl0001' then return end

    WaitTicks( Random(50,650) )  -- to avoid the artificial appearance when all AI players use their intel probe at the same time

    local brain = cdr:GetAIBrain()
    local AbilityName = 'NomadsAreaBombardment'
    local AbilityDef = import('/lua/abilitydefinition.lua').abilities[AbilityName]
    local AbilityCooldown = AbilityDef.ExtraInfo.CoolDownTime + 1
    local TargetLocDeviation = 0
    local LastTargets = {}
    local LastTargetsCounter = 1
    local location, targetUnits, target, friendlies, TMDs, range, upos, tpos, DoRangeCheck, AbilityRangeCheckUnits, BestUnit, BestUnitAdjNum, UnitAdjNum

    local BombardUnitBp = __blueprints['xno0001']
    local Damage = BombardUnitBp.Weapon[1].Damage
    local DamageRadius = BombardUnitBp.Weapon[1].DamageRadius  -- damage radius of the missiles
    local NumTargets = BombardUnitBp.SpecialAbilities.NomadsAreaBombardment.WantNumTargets or 1
    local TargetDist = 2 * (BombardUnitBp.SpecialAbilities.NomadsAreaBombardment.AreaOfEffect or DamageRadius)
    local DoSpreadAttack = false
    local TMDcat = categories.ANTIMISSILE - categories.STRATEGIC
    local TMDrange = 28

    -- respect difficulty setting since this can be a very annoying ability for noobs
    local AIpersonality = ScenarioInfo.ArmySetup[brain.Name].AIPersonality
    if AIpersonality == 'easy' then
        TargetLocDeviation = 6
        AbilityCooldown = AbilityCooldown * 3
    elseif AIpersonality == 'medium' then
        TargetLocDeviation = 3
        AbilityCooldown = AbilityCooldown * 2
    end

    while not cdr.Dead do

        target = false

        -- check ACU enhancements
        while not cdr:HasEnhancement('OrbitalBombardment') do
            WaitSeconds(5.1)
        end

        -- decide if we need to do range checks
        DoRangeCheck = AbilityDef.ExtraInfo.DoRangeCheck
        if DoRangeCheck then
            AbilityRangeCheckUnits = brain:GetUnitsWithAbility(abilityName)
            for k, unit in AbilityRangeCheckUnits do
                if unit:GetBlueprint().SpecialAbilities[AbilityName].MaxRadius == -1 then
                    DoRangeCheck = false
                    break
                end
            end
        end

        -- find a target
        if DoRangeCheck then

            for _, cat in CommanderBombardPriorityList do
                for k, unit in AbilityRangeCheckUnits do
                    upos = unit:GetPosition()
                    range = unit:GetBlueprint().SpecialAbilities[AbilityName].MaxRadius
                    if range == 0 then
                        continue
                    end
                    targetUnits = brain:GetUnitsAroundPoint( cat, upos, range, 'Enemy' )

                    for l, targetUnit in targetUnits do

                        -- skip dead and moving targets
                        if targetUnit:BeenDestroyed() or targetUnit.Dead or targetUnit:IsUnitState('Moving') or targetUnit:IsUnitState('Attached') or targetUnit:IsUnitState('Patrolling') then
                            continue
                        end

                        -- second distance check (square vs circle)
                        tpos = targetUnit:GetPosition()
                        if VDist2( upos[1], upos[3], tpos[1], tpos[3] ) > range then
                            continue
                        end

                        -- dont persist attacking, if we didnt kill it in the previous 3 times we probably wont the next time either.
                        if table.count( LastTargets, targetUnit.EntityId ) >= 3 then
                            continue
                        end

                        -- check for nearby friendlies. If we're about to kill the target unit anyway then pick another target
                        friendlies = brain:GetUnitsAroundPoint( categories.MOBILE, tpos, 15, 'Ally' )
                        if table.getsize( friendlies ) > 2 then
                            continue
                        end

                        -- check for nearby enemy TMD. NO use trying to destroy something surrounded by plenty of TMD
                        TMDs = brain:GetUnitsAroundPoint( TMDcat, tpos, TMDrange, 'Enemy' )
                        if table.getsize( TMDs ) > 7 then
                            continue
                        end

                        target = GetUnitById( targetUnit.EntityId )
                        break
                    end

                    if target then
                        break
                    end
                end

                if target then
                    break
                end
            end

        else

            for _, cat in CommanderBombardPriorityList do
                targetUnits = brain:GetUnitsAroundPoint( cat, cdr:GetPosition(), 99999, 'Enemy' )

                for l, targetUnit in targetUnits do

                    -- skip dead and moving targets
                    if targetUnit:BeenDestroyed() or targetUnit.Dead or targetUnit:IsUnitState('Moving') or targetUnit:IsUnitState('Attached') or targetUnit:IsUnitState('Patrolling') then
                        continue
                    end

                    -- dont persist attacking, if we didnt kill it in the previous 3 times we probably wont the next time either.
                    if table.count( LastTargets, targetUnit.EntityId ) >= 3 then
                        continue
                    end

                    tpos = targetUnit:GetPosition()

                    -- check for nearby friendlies. If we're about to kill the target unit anyway then pick another target
                    friendlies = brain:GetUnitsAroundPoint( categories.MOBILE, tpos, 15, 'Ally' )
                    if table.getsize( friendlies ) > 2 then
                        continue
                    end

                    -- check for nearby enemy TMD. NO use trying to destroy something surrounded by plenty of TMD
                    TMDs = brain:GetUnitsAroundPoint( TMDcat, tpos, TMDrange, 'Enemy' )
                    if table.getsize( TMDs ) > 7 then
                        continue
                    end

                    target = GetUnitById( targetUnit.EntityId )
                    break
                end

                if target then
                    break
                end
            end
        end

        AbilityRangeCheckUnits = nil
        targetUnits = nil
        friendlies = nil
        TMDs = nil

        if target then

            LastTargets[ LastTargetsCounter ] = target.EntityId
            LastTargetsCounter = LastTargetsCounter + 1
            if LastTargetsCounter > 10 then
               LastTargetsCounter = 1
            end

            -- find best target location for maximum damage but still hit the target
            BestUnit = target
            BestUnitAdjNum = 0
            location = table.copy( target:GetPosition() )
            targetUnits = brain:GetUnitsAroundPoint( categories.STRUCTURE - categories.WALL, location, (DamageRadius * 2), 'Enemy' )
            for k, targetUnit in targetUnits do

                -- check range from targetUnit to other units ONLY for units who are close enough to our real target. We still wannt to hit
                -- our real target, this is just an optimization.
                tpos = targetUnit:GetPosition()
                if VDist2(location[1], location[3], tpos[1], tpos[3]) <= DamageRadius then  -- range check, find units close to real target

                    -- count number of adjacent units. If more than BestUnitAdjNum then this is our new best target
                    UnitAdjNum = 0
                    for _, u in targetUnits do
                        upos = u:GetPosition()
                        if VDist2(upos[1], upos[3], tpos[1], tpos[3]) <= DamageRadius then  -- range check
                            UnitAdjNum = UnitAdjNum + 1
                        end
                    end
                    if UnitAdjNum > BestUnitAdjNum then
                        BestUnit = GetUnitById( targetUnit.EntityId )
                        BestUnitAdjNum = UnitAdjNum
                    end
                end
            end

            --LOG('*DEBUG: AI orbital bombardment targetting '..repr(BestUnit:GetUnitId())..', number of nearby units is '..repr(BestUnitAdjNum)..', real target is '..repr(target:GetUnitId()))
            location = table.copy( BestUnit:GetPosition() )
            DoSpreadAttack = (BestUnit:GetMaxHealth() <= Damage) or (BestUnit:GetHealth() <= (Damage * 0.75))
        end

        if location then

            -- apply deviation
            if TargetLocDeviation > 0 then
                location[1] = location[1] + Random(-TargetLocDeviation, TargetLocDeviation)
                location[3] = location[3] + Random(-TargetLocDeviation, TargetLocDeviation)
            end

            -- prepare script command
            local UnitId = brain.NomadsMothership.EntityId
            local ExtraInfo = AbilityDef.ExtraInfo
            local angle = RandomFloat(0, math.pi)
            if DoSpreadAttack then
                local targets = {}
                local r, x, z, pos
                local angleInc = (2*math.pi) / (NumTargets-1)
                targets[1] = {
                        ['Position'] = {location[1], location[2], location[3]},
-- TODO: this. Create reticules here so human allies can see?
--                        ['ReticuleId'] =
                        ['UnitId'] = UnitId,
                }
                for i = 2, NumTargets do
                    r = (angle + (angleInc * i))
                    x = location[1] + (math.sin(r) * TargetDist)
                    z = location[3] + (math.cos(r) * TargetDist)
                    targets[i] = {
                        ['Position'] = {x, location[2], z},
-- TODO: this. Create reticules here so human allies can see?
--                        ['ReticuleId'] =
                        ['UnitId'] = UnitId,
                    }
                end
                ExtraInfo['Targets'] = targets
            else
                local targets = {}
                local r, x, z, pos
                local angleInc = (2*math.pi) / NumTargets
                for i = 1, NumTargets do
                    r = (angle + (angleInc * i))
                    x = location[1] + (math.sin(r) * TargetDist * 0.5)
                    z = location[3] + (math.cos(r) * TargetDist * 0.5)
                    targets[i] = {
                        ['Position'] = {x, location[2], z},
-- TODO: this. Create reticules here so human allies can see?
--                        ['ReticuleId'] =
                        ['UnitId'] = UnitId,
                    }
                end
                ExtraInfo['Targets'] = targets
            end

            ExtraInfo['AI'] = true
            commandData = {
                Behaviour = AbilityDef.UIBehaviorSingleClick,
                ExtraInfo = ExtraInfo,
                Location = location,
                UnitIds = { UnitId, },
                TaskName = AbilityName,
            }


            -- launch bombardment at found location
            IssueScript( brain:GetUnitsWithAbility(abilityName), commandData )

            target = nil
            targetUnits = nil
            BestUnit = nil

            -- Wait till ability is available again
            WaitSeconds( AbilityCooldown )

        else
            -- no suitable location found for bombardment: wait a bit before checking for another location
            WaitSeconds(15)
        end
    end
end

function OrbitalBombardmentThreadSorian(cdr, platoon)
    OrbitalBombardmentThread(cdr, platoon)
end

function CommanderIntelProbeThread(cdr, platoon)
    if cdr:GetUnitId() ~= 'xnl0001' then
        return
    end

    --LOG('*DEBUG: AI CommanderIntelProbeThread')

    WaitTicks( Random(50,650) )  -- to avoid the artificial appearance when all AI players use their intel probe at the same time

    local brain = cdr:GetAIBrain()

    local ProbeEnabled, ProbeAdvEnabled = false, false
    local LastPositions = {}
    local LastPositionsCounter = 1
    local cdrPos, AbilityDef, AbilityName, location, possibleLocs, markerList, units
    local IntelRadius = 0

    local AUcat = categories.ALLUNITS - categories.WALL
    local TMDcat = categories.ANTIMISSILE - categories.STRATEGIC
    local TMDrange = 28
    local LastLocType = 2

    -- respect difficulty setting
    local AIpersonality = ScenarioInfo.ArmySetup[brain.Name].AIPersonality
    if AIpersonality == 'easy' then
        --LOG('*DEBUG: CommanderIntelProbeThread to easy')
        TMDrange = 3
    elseif AIpersonality == 'medium' then
        --LOG('*DEBUG: CommanderIntelProbeThread to medium')
        TMDrange = 15
    end

    while not cdr.Dead do

        -- check ACU enhancements
        while not cdr:HasEnhancement('IntelProbe') and not cdr:HasEnhancement('IntelProbeAdv') do
            WaitSeconds(5.1)
        end

        -- set variables
        if cdr:HasEnhancement('IntelProbeAdv') ~= ProbeAdvEnabled then

            ProbeAdvEnabled = cdr:HasEnhancement('IntelProbeAdv')
            if not ProbeAdvEnabled then
                continue   -- if this enhancement is no longer available...
            end

            ProbeEnabled = false
            AbilityName = 'NomadsIntelProbeAdvanced'
            AbilityDef = import('/lua/abilitydefinition.lua').abilities[AbilityName]
            IntelRadius = 0.8 * (AbilityDef.ExtraInfo.Radius or 50)

        elseif cdr:HasEnhancement('IntelProbe') ~= ProbeEnabled then

            ProbeEnabled = cdr:HasEnhancement('IntelProbe')
            if not ProbeEnabled then
                continue   -- if this enhancement is no longer available...
            end

            AbilityName = 'NomadsIntelProbe'
            AbilityDef = import('/lua/abilitydefinition.lua').abilities[AbilityName]
            IntelRadius = 0.8 * (AbilityDef.ExtraInfo.Radius or 50)

        end

        -- find a location (using LastLocType to skip types that previously didn't return results, subtracting one so we can retry types)
        -- assuming that there are always mass deposits near interesting sites i've disabled looking for expansion bases and starting points
        location = false
--        for i = math.max(1, (LastLocType-1)), 6 do
        for i = math.max(1, (LastLocType-1)), 2 do

            possibleLocs = {}

--            if i == 1 then        -- starting locations where no units are (as far as we know)
--                markerList = AIUtils.AIGetStartLocations( brain )
--                for _, v in markerList do
--                    units = brain:GetUnitsAroundPoint( AUcat, v, 25, 'Enemy' )
--                    if units and table.getsize( units ) < 1 then
--                        table.insert( possibleLocs, v )
--                    end
--                end

--            elseif i == 2 then    -- mass deposits where no units are (as far as we know)
            if i == 1 then    -- mass deposits where no units are (as far as we know)
                markerList = AIUtils.AIGetMarkerLocations( brain, 'Mass' )
                for _, v in markerList do
                    units = brain:GetUnitsAroundPoint( AUcat, v.Position, 25, 'Enemy' )
                    if units and brain:CanBuildStructureAt( 'ueb1103', v.Position ) and table.getsize( units ) < 1 then
                        table.insert( possibleLocs, v.Position )
                    end
                end

--            elseif i == 3 then    -- defensive locations (expansion bases?) where no units are (as far as we know)
--                markerList = AIUtils.AIGetSortedDefensiveLocations( brain )
--                for _, v in markerList do
--                    units = brain:GetUnitsAroundPoint( AUcat, v.Position, 25, 'Enemy' )
--                    if units and table.getsize( units ) < 1 then
--                        table.insert( possibleLocs, v.Position )
--                    end
--                end

--            elseif i == 4 then    -- starting locations where units are
--                markerList = AIUtils.AIGetStartLocations( brain )
--                for _, v in markerList do
--                    units = brain:GetUnitsAroundPoint( AUcat, v, 25, 'Enemy' )
--                    if units and table.getsize( units ) >= 1 then
--                        table.insert( possibleLocs, v.Position )
--                    end
--                end

--            elseif i == 5 then    -- mass deposits where units are
            elseif i == 2 then    -- mass deposits where units are
                markerList = AIUtils.AIGetMarkerLocations( brain, 'Mass' )
                for _, v in markerList do
                    units = brain:GetUnitsAroundPoint( AUcat, v.Position, 25, 'Enemy' )
                    if units and table.getsize( units ) >= 1 then
                        table.insert( possibleLocs, v.Position )
                    end
                end

--            elseif i == 6 then    -- defensive locations (expansion bases?) where units are
--                markerList = AIUtils.AIGetSortedDefensiveLocations( brain )
--                for _, v in markerList do
--                    units = brain:GetUnitsAroundPoint( AUcat, v.Position, 25, 'Enemy' )
--                    if units and table.getsize( units ) >= 1 then
--                        table.insert( possibleLocs, v.Position )
--                    end
--                end

            end

            -- find a suitable location. Not suitable: places where we already have units nearby or where there's a TMD nearby
            for _, loc in possibleLocs do

                -- make sure that we're not close to a previous location
                ToClose = false
                for k, v in LastPositions do
                    if VDist2( v[1], v[3], loc[1], loc[3] ) < IntelRadius then
                        ToClose = true
                        break
                    end
                end

                if    not ToClose
                and   table.getsize( brain:GetUnitsAroundPoint( AUcat,  loc, 25, 'Ally' )) < 1
                and   table.getsize( brain:GetUnitsAroundPoint( TMDcat, loc, TMDrange, 'Enemy' )) < 1
                then
                    location = table.copy(loc)
                    location[1] = location[1] + Random(-5, 5)
                    location[3] = location[3] + Random(-5, 5)
                    break
                end
            end

            LastLocType = i
            if location then break end
        end

        -- in case we still don't have a position...
        if not location then
            local bestUnit, bestBase = FindExperimentalTarget(cdr)
            if bestUnit and IsUnit(bestUnit) then
                location = table.copy( bestUnit:GetPosition() )
            end
        end

        if location then
            LastPositions[LastPositionsCounter] = location
            LastPositionsCounter = LastPositionsCounter + 1
            if LastPositionsCounter >= 15 then
                LastPositionsCounter = 1
            end

            -- launch probe at found location
            commandData = {
                ExtraInfo = AbilityDef.ExtraInfo,
                Location = location,
                TaskName = AbilityName,
            }
            IssueScript( brain:GetUnitsWithAbility(abilityName), commandData )

            -- Wait till ability is available again
            WaitSeconds( AbilityDef.ExtraInfo.CoolDownTime + 0.5 )

        else
            -- no suitable location found for intel probe: wait a bit before checking for another location
            WaitSeconds(30)
        end
    end
end

function CommanderIntelProbeThreadSorian(cdr, platoon)
    CommanderIntelProbeThread(cdr, platoon)
end



end