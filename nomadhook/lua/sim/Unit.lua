do

local oldUnit = Unit

Unit = Class(oldUnit) {

    -- ================================================================================================================
    -- improved emitter features
    --we add the functionality to change the colour of emitters based on the units faction colour.
    --this is done via a specially made ramp texture containing all the faction colours,
    --and then using SetEmitterCurveParam to change the colour via script.

    OnPreCreate = function(self)
        --yes i know this is disgusting but it has to be done since the nomads orbital ship crashes the game
        --so it needs an exception FIXME: refactor nomads orbital frigate so its not so crazy.
        if not self.ColourIndex then
            self:DetermineColourIndex()
        end

        oldUnit.OnPreCreate(self)
    end,

        CreateTerrainTypeEffects = function( self, effectTypeGroups, FxBlockType, FxBlockKey, TypeSuffix, EffectBag, TerrainType )
        local army = self:GetArmy()
        local pos = self:GetPosition()
        local effects = {}
        local emit

        for kBG, vTypeGroup in effectTypeGroups do
            if TerrainType then
                effects = TerrainType[FxBlockType][FxBlockKey][vTypeGroup.Type] or {}
            else
                effects = self.GetTerrainTypeEffects( FxBlockType, FxBlockKey, pos, vTypeGroup.Type, TypeSuffix )
            end

            if not vTypeGroup.Bones or (vTypeGroup.Bones and (table.getn(vTypeGroup.Bones) == 0)) then
                WARN('*WARNING: No effect bones defined for layer group ',repr(self:GetUnitId()),', Add these to a table in Display.[EffectGroup].', self:GetCurrentLayer(), '.Effects { Bones ={} } in unit blueprint.' )
            else
                for kb, vBone in vTypeGroup.Bones do
                    for ke, vEffect in effects do
                        emit = CreateAttachedEmitter(self,vBone,army,vEffect):ScaleEmitter(vTypeGroup.Scale or 1)
                        if vTypeGroup.Offset then
                            emit:OffsetEmitter(vTypeGroup.Offset[1] or 0, vTypeGroup.Offset[2] or 0,vTypeGroup.Offset[3] or 0)
                        end
                        if vTypeGroup.Recolour then
                            --WARN('Trying to recolour emitter (make sure it has a ramp compatible with this feature): '..vEffect)
                            emit:SetEmitterCurveParam('RAMPSELECTION_CURVE', 1-((self.ColourIndex)*(1/18))+1/36, 0)
                            --WARN('recolouring emitter'..(self.ColourIndex)*(1/18)..' with index of: '..self.ColourIndex)
                        end
                        if EffectBag then
                            table.insert( EffectBag, emit )
                        end
                    end
                end
            end
        end
    end,

    DetermineColourIndex = function(self)
        --we determine the index once on create then save it in the entity table to save on sim slowdown
        --WARN('setting colour index for blueprintID: ' .. self:GetUnitId())
        local tblArmy = ListArmies()
        local army = self:GetArmy()
        self.ColourIndex = ScenarioInfo.ArmySetup[tblArmy[army]].ArmyColor
    end,





    OnCreate = function(self)
        oldUnit.OnCreate(self)
        self._IsSuckedInBlackHole = false
        self.SpeedMulti = 1
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        oldUnit.OnStopBeingBuilt(self, builder, layer)
        self:RegisterSpecialAbilities()
        self:MonitorAmmoCount()
        self:UpdateWeaponLayers(layer, 'None')
    end,

    


    UpdateWeaponLayers = function(self, new, old)
        -- TODO: this could/should include the SetValidTargetsForCurrentLayer part from OnLayerChange()
        local NewIsWater = (new == 'Water' or new == 'Sub' or new == 'Seabed')
        local OldIsWater = (old == 'Water' or old == 'Sub' or old == 'Seabed')
        local c = self:GetWeaponCount()
        local wep, wepbp, label
        for w=1, c do
            wep = self:GetWeapon(w)
            if NewIsWater ~= OldIsWater then
                wepbp = wep:GetBlueprint()
                if wepbp.OnWaterDisable then
                    self:SetWeaponEnabledByLabel( wepBp.Label, not NewIsWater )
                end
            end
            wep:OnLayerChange(new, old)
        end
    end,

    -- ================================================================================================================
    -- NEW GENERIC EVENTS

    OnShieldRemoved = function(self)
        -- happens when the shield bubble is gone for whatever reason. "OnShieldEnabled" is fired when the shield is back on
    end,

    -- ================================================================================================================
    -- AMMO EVENTS

    OnAmmoCountIncreased = function(self, NewCount)
        -- event fires when the counted projectile weapon ammo count increased whatever reason. Polls every 2 ticks.
        --LOG('*DEBUG: OnAmmoCountIncreased NewCount = '..repr(NewCount))
        if NewCount > 0 then
            self:SpecialAbilitySetAvailability(true)
        end
    end,

    OnAmmoCountDecreased = function(self, NewCount)
        -- event fires when the counted projectile weapon ammo count decreased after firing a missile.
        --LOG('*DEBUG: OnAmmoCountDecreased NewCount = '..repr(NewCount))
        if NewCount < 1 then
            self:SpecialAbilitySetAvailability(false)
        end
    end,

    NukeCreatedAtUnit = function(self)
        -- when the unit launches a counted nuke.
        oldUnit.NukeCreatedAtUnit(self)
    end,

    TacMissileCreatedAtUnit = function(self)
        -- when the unit launches a counted tactical missile.
    end,

    GiveNukeSiloAmmo = function(self, count)
        --LOG('*DEBUG: GiveNukeSiloAmmo calling OnAmmoCountIncreased')
        local NewCount = count + self:GetNukeSiloAmmoCount()
        oldUnit.GiveNukeSiloAmmo(self, count)
        self:OnAmmoCountIncreased(NewCount)
    end,

    GiveTacticalSiloAmmo = function(self, count)
        --LOG('*DEBUG: GiveTacticalSiloAmmo calling OnAmmoCountIncreased')
        local NewCount = count + self:GetTacticalSiloAmmoCount()
        oldUnit.GiveTacticalSiloAmmo(self, count)
        self:OnAmmoCountIncreased(NewCount)
    end,

    RemoveNukeSiloAmmo = function(self, count)
        --LOG('*DEBUG: RemoveNukeSiloAmmo calling OnAmmoCountDecreased')
        local NewCount = self:GetNukeSiloAmmoCount() - count
        oldUnit.RemoveNukeSiloAmmo(self, count)
        self:OnAmmoCountDecreased(NewCount)
    end,

    RemoveTacticalSiloAmmo = function(self, count)
        --LOG('*DEBUG: RemoveTacticalSiloAmmo calling OnAmmoCountDecreased')
        local NewCount = self:GetTacticalSiloAmmoCount() - count
        oldUnit.RemoveTacticalSiloAmmo(self, count)
        self:OnAmmoCountDecreased(NewCount)
    end,

    MonitorAmmoCount = function(self)
        -- if using counted projectiles then monitors the ammo and fires event OnAmmoCountChanged when ammo changed
        local DoMonitor = false
        local bp, wep, IsNuke
        local NumWep = self:GetWeaponCount()
        for i=1, NumWep do
            wep = self:GetWeapon(i)
            bp = wep:GetBlueprint()
            if bp.CountedProjectile == true then
                DoMonitor = true
                IsNuke = bp.NukeWeapon or false
                break
            end
        end

        if DoMonitor then
            local fn = function(self, nuke)
                local old, new = 0, 0
                WaitTicks(2)
                while self and not self.Dead do
                    if nuke then
                        new = self:GetNukeSiloAmmoCount()
                    else
                        new = self:GetTacticalSiloAmmoCount()
                    end
                    if new > old then
                        --LOG('*DEBUG: MonitorAmmoCount calling OnAmmoCountIncreased')
                        self:OnAmmoCountIncreased(new)
                    end
                    old = new
                    WaitTicks(2)
                end
            end
            self:ForkThread(fn, IsNuke)
        end
    end,

    -- ================================================================================================================
    -- TRANSPORT EVENTS

    --pending integration into main game; adds support for custom animation speeds.
    TransportAnimationThread = function(self, rate)
        local bp = self:GetBlueprint().Display
        local animbp
        rate = rate or 1

        if rate < 0 and bp.TransportDropAnimation then
            animbp = bp.TransportDropAnimation
            rate = bp.TransportDropAnimationSpeed or -rate
        else
            animbp = bp.TransportAnimation
            rate = bp.TransportAnimationSpeed or rate
        end

        WaitSeconds(.5)
        if animbp then
            local animBlock = self:ChooseAnimBlock(animbp)
            if animBlock.Animation then
                if not self.TransAnimation then
                    self.TransAnimation = CreateAnimator(self)
                    self.Trash:Add(self.TransAnimation)
                end
                self.TransAnimation:PlayAnim(animBlock.Animation)
                self.TransAnimation:SetRate(rate)
                WaitFor(self.TransAnimation)
            end
        end
    end,
    
    OnAddToStorage = function(self, carrier)
        -- fires when a unit is stored in a carrier (also for refueling)
        carrier:OnUnitAddedToStorage(self)
        oldUnit.OnAddToStorage(self, carrier)
    end,

    OnRemoveFromStorage = function(self, carrier)
        -- fires when a unit is launched from a carrier
        carrier:OnUnitRemovedFromStorage(self)
        oldUnit.OnRemoveFromStorage(self, carrier)
    end,

    OnUnitAddedToStorage = function(self, unit)
    end,

    OnUnitRemovedFromStorage = function(self, unit)
    end,

    -- ================================================================================================================
    -- BEING BUFFED (by something else)

    OnBeforeBeingBuffed = function( self, buffName, instigator, AOEtargetUnit)
        -- return something to be used in the 'after' event function
    end,

    OnAfterBeingBuffed = function( self, buffName, instigator, AOEtargetUnit, beforeData)
    end,

    AddBuff = function(self, buffTable, PosEntity, AOEtargetUnit)
        -- If applying a stun buff with a radius, DONT forget to stun "self". Bug: stun buff with radius doens't stun factories. Caused by
        -- offset between projectile impact and origin bone of the unit. If the distance between these two is bigger than the radius then the
        -- factory (in this case) isn't stunned. See it like this:     [X = impact, ) is edge of radius check, O is origin bone].
        --
        --    X-----)-O
        --
        -- Impact offset is caused by hitbox size.
        --
        -- Added argument AOEtarget which is provided by projectile.lua when there's an area of effect (radius) specified. We'll also stun
        -- this unit.

        local bt = buffTable.BuffType
        if bt and bt == 'STUN' and buffTable.Radius and buffTable.Radius > 0 then --and AOEtargetUnit and IsUnit(AOEtargetUnit)

            local targets = {}
            if PosEntity then
                if buffTable.ApplyToFriendly then   -- new info, allows to target friendly units aswell
                    targets = utilities.GetAllUnitsInSphere(PosEntity, buffTable.Radius)
                else
                    targets = utilities.GetEnemyUnitsInSphere(self, PosEntity, buffTable.Radius)
                end
            else
                if buffTable.ApplyToFriendly then
                    targets = utilities.GetAllUnitsInSphere(self:GetPosition(), buffTable.Radius)
                else
                    targets = utilities.GetEnemyUnitsInSphere(self, self:GetPosition(), buffTable.Radius)
                end
            end

            if targets then

                if AOEtargetUnit then
                    -- making sure we apply the buff to AOEtargetUnit and that we do it only once. It could be in targets already, or not.
                    table.removeByValue(targets, AOEtargetUnit)
                    table.insert( targets, AOEtargetUnit )
                end

                -- parse restriction categories
                local allow = categories.ALLUNITS
                if buffTable.TargetAllow then
                    allow = ParseEntityCategory(buffTable.TargetAllow)
                end
                local disallow
                if buffTable.TargetDisallow then
                    disallow = ParseEntityCategory(buffTable.TargetDisallow)
                end

                for k, v in targets do
                    if EntityCategoryContains(allow, v) and (not disallow or not EntityCategoryContains(disallow, v)) then
                        local data = v:OnBeforeBeingBuffed(buffTable.Name, self)
                        v:SetStunned(buffTable.Duration or 1)
                        v:OnAfterBeingBuffed(buffTable.Name, self, nil, data)
                    end
                end
            end

        else

            local data = self:OnBeforeBeingBuffed(buffTable.Name, self)
            oldUnit.AddBuff(self, buffTable, PosEntity, AOEtargetUnit)
            self:OnAfterBeingBuffed(buffTable.Name, self, nil, data)
        end
    end,

    AddWeaponBuff = function(self, buffTable, weapon)
        -- don't think these are used but for consistency I'm adding the new events here aswell. Notice that there's no instigator.
        local beforeData = self:OnBeforeBeingBuffed( buffTable.Name )
        oldUnit.AddWeaponBuff(self, buffTable, weapon)
        self:OnAfterBeingBuffed( buffTable.Name, nil, beforeData )
    end,

    SetSpeedMult = function(self, val)
        -- Fixing a bug in the engine, the speed multi is multiplied with itself before applied to the unit, resuling in an excessive
        -- speed multi (0.8 becomes 0.64,etc). This only happens when the multi is < 1. Fixing this by taking the square root of the passed
        -- value instead, if it is below 1. Test by having a Nomads hover unit with reduced speed on water through a buff and another hover
        -- unit. Move them over water and compare speeds.
        self.SpeedMulti = val
        if val < 1 then
            val = math.sqrt(val)
        end
        --LOG('*DEBUG: SetSpeedMult '..repr(self:GetUnitId())..' '..repr(val))
        return oldUnit.SetSpeedMult(self, val)
    end,

    GetSpeedMult = function(self)
        return self.SpeedMulti
    end,

    -- ================================================================================================================
    -- BEING STUNNED STUFF

    CanBeStunned = function(self)
        if self:GetCurrentLayer() == 'Air' then
            return false
        elseif self:ShieldIsOn() and self:ShieldIsPersonalShield() then
            return false
        elseif EntityCategoryContains( categories.UNSTUNABLE, self ) then
            return false
        end
        return true
    end,

    SetStunned = function(self, duration, forced)
        if self:CanBeStunned() or forced then
            local fn = function(self, duration)
                WaitSeconds( duration )
                self._IsStunned = false
                self:OnStunnedOver(self)
            end
            if self.StunnedThread then  -- if unit it hit twice by stun weapon then this ensures the second hit prolongs the stun
                KillThread( self.StunnedThread )
                self.StunnedThread = nil
            end
            self._IsStunned = true
            self.StunnedThread = self:ForkThread(fn, duration)
            self:OnStunned(duration)
            return oldUnit.SetStunned(self, duration) or true
        end
        return false
    end,

    IsStunned = function(self)
        return self._IsStunned or false
    end,

    OnStunned = function(self, duration)
        local bp = self:GetBlueprint()

        -- change appearance while stunned
        self:SetMesh( bp.Display.MeshBlueprintStunned, true)

        -- stop resource consumption
        self:SetMaintenanceConsumptionInactive()

        -- collapse shield (if any)
        if self.MyShield and self.MyShield.CollapseShield then
            -- if a shield generator unit is stunned then collapse its shield
            if not bp.Defense.Shield.NoStunShieldCollapse then
                self.MyShield:CollapseShield( self )  -- TODO: Check if this can be done better, I think there's already a method to do this.
            end
        end

        -- disable intel
        if self.IntelDisables and type(self.IntelDisables) == 'table' then
            self:DisableUnitIntel('stunned', 'Radar')
            self:DisableUnitIntel('stunned', 'Sonar')
        end

        -- stop weapon salvos
        if self:GetWeaponCount() > 0 then
            local wep
            for i = 1, self:GetWeaponCount() do
                wep = self:GetWeapon(i)
                if wep then
                    wep:OnHaltFire()
                    --LOG('*DEBUG: OnStunned weapon '..repr(i)..' OnHaltFire')
                end
            end
        end
    end,

    OnStunnedOver = function(self)
        -- change appearance back to normal
        self:SetMesh( self:GetBlueprint().Display.MeshBlueprint, true)

        -- allow resource consumption again
        self:SetMaintenanceConsumptionActive()

        -- enable intel
        if self.IntelDisables then
            self:EnableUnitIntel('stunned', 'Radar')
            self:EnableUnitIntel('stunned', 'Sonar')
        end

        -- make sure weapons can fire again (set variable haltfireordered to false)
        if self:GetWeaponCount() > 0 then
            local wep
            for i = 1, self:GetWeaponCount() do
                wep = self:GetWeapon(i)
                if wep then
                    wep:OnUnhaltFire()
                end
            end
        end
    end,

    -- ================================================================================================================
    -- SHIELDS

    ShieldIsPersonalShield = function(self)
        -- returns true if the shield on the unit is a personal shield, no otherwise (also when no shield used)
        if self.MyShield then
            return self.MyShield.ShieldType == 'Personal' or false
        end
        return false
    end,

    CreateShield = function(self, shieldSpec)
        oldUnit.CreateShield(self, shieldSpec)
        if self.MyShield then
            self.MyShield.IsPersonalShield = false
        end
    end,

    CreateAntiArtilleryShield = function(self, shieldSpec)
        oldUnit.CreateAntiArtilleryShield(self, shieldSpec)
        if self.MyShield then
            self.MyShield.IsPersonalShield = false
        end
    end,

    CreatePersonalShield = function(self, shieldSpec)
        oldUnit.CreatePersonalShield(self, shieldSpec)
        if self.MyShield then
            self.MyShield.IsPersonalShield = true
        end
    end,

    -- ================================================================================================================
    -- BLACK HOLE SUCK IN STUFF

    WasUnitKilledByBlackhole = function(self, DmgType)
        if DmgType == 'BlackholeDamage' or DmgType == 'BlackholeDeathNuke' then
            return true
        end
        return false
    end,
    
    IsSuckedInBlackHole = function(self)
        return self._IsSuckedInBlackHole or false
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
        self:UnregisterSpecialAbilities()
        if self:WasUnitKilledByBlackhole(type) then
            self._IsSuckedInBlackHole = true
        end
        oldUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    DeathThread = function(self, overkillRatio, instigator)
        --we replace the death thread with another one for units killed by black holes
        if self._IsSuckedInBlackHole then
            self:DeathThreadBlackHole(overkillRatio, instigator)
        else
            oldUnit.DeathThread(self, overkillRatio, instigator)
        end
    end,

    DeathThreadBlackHole = function(self, overkillRatio, instigator)
        --self._IsSuckedInBlackHole = true
        if not instigator.NukeEntity then 
            WARN('could not find nuke entity, proceeding with regular death')
            oldUnit.DeathThread(self, overkillRatio, instigator)
            return
        end
        
        self.overkillRatio = overkillRatio
        self:SetCollisionShape('None')

        self:DestroyAllDamageEffects()
        self:DestroyTopSpeedEffects()
        self:DestroyMovementEffects()
        self:DestroyIdleEffects()

        if self.TarmacBag then
            self:DestroyTarmac()
        end
            
        -- This is a bit complex. The slider used below uses a relative direction. To feed the correct destinations to the slider
        -- we need to calculate the angle of the black hole relative to the unit, the units angle on the world map and the distance
        -- to the black hole.
        local Utilities = import('/lua/utilities.lua')
        -- distance to black hole
        local pos = self:GetPosition()
        local HolePos = instigator.NukeEntity:GetPosition()
        local dist = VDist3(pos, HolePos)

        -- unit direction (from vector to angle (rad))
        local selfDirX, selfDirY, selfDirZ = self:GetBoneDirection(0)
        local selfDir = Utilities.NormalizeVector( Vector( selfDirX, 0, selfDirZ) )

        -- blackhole direction relative to unit (from vector to angle (rad))
        local target = table.deepcopy(HolePos)
        target[1] = target[1] - pos.x
        target[2] = 0
        target[3] = target[3] - pos.z
        target['x'] = target[1]
        target['y'] = target[2]
        target['z'] = target[3]
        target = Utilities.NormalizeVector(target)

        -- determine angle: blackhole direction - unit direction
        local angle = ((2/math.pi) - math.atan2(target.x,target.z)) - ((2/math.pi) - math.atan2(selfDir.x,selfDir.z))

        -- calculate slider coordinates
        local ox = -dist * (math.sin(angle))
        local oy = HolePos[2] - pos[2]
        local oz = dist * (math.cos(angle))


        -- Using a slider to create the drift in effect
        self:SetImmobile(true)  -- fix crash with landed aircraft
        self.BlackholeSlider = CreateSlider(self, 0, ox, oy, oz, 0, true)
        self.BlackholeSlider:SetGoal(ox, oy, oz)
        self.BlackholeSlider:SetSpeed(2)
        --self.BlackholeSlider:SetAcceleration(3) --for some reason this doesnt actually work :/
        self.BlackholeSlider:SetWorldUnits(true)
        self.Trash:Add( self.BlackholeSlider )
        
        self.BlackholeRotator = CreateRotator(self, 0, 'x', nil, 0, 10, 180)
        self.Trash:Add( self.BlackholeRotator )

        self:OnStartBeingSuckedInBlackhole(instigator.NukeEntity)

        -- let black hole know we're being sucked in
        if instigator.NukeEntity.OnUnitBeingSuckedIn then
            instigator.NukeEntity:OnUnitBeingSuckedIn(self)
        end

        --since the acceleration on the slider doesnt work, and WaitFor already loops every second we can just make a manual loop and add in our acceleration there.
        --ugly code but it works, i blame gpg. maybe one day SetAcceleration will work
        --WaitSeconds(3)
        local waitTicks = 30
        for i = 1, waitTicks do
            self.BlackholeSlider:SetSpeed(2+(i*0.3))
            WaitTicks(1)
        end
        WaitFor( self.BlackholeSlider )

        pos = self:GetPosition(0)
        local ori = self:GetOrientation()
        self.BlackholeSlider:Destroy()

        -- Units built on map markers need to not warp or the marker is unbuilable afterwards. I think the engine
        -- checks the dead units position against all markers and clears a flag for the marker found at the location
        -- of the unit. By warping the unit its position changes and the engine can't find the marker anymore.
        if not (self:GetBlueprint().Physics.BuildRestriction and self:GetBlueprint().Physics.BuildRestriction ~= '') then
            Warp( self, pos, ori )
        end

        -- let black hole know we've been sucked in
        if instigator.NukeEntity.OnUnitSuckedIn then
            instigator.NukeEntity:OnUnitSuckedIn(self, self.overkillRatio)
        end
        
        self:VeterancyDispersal()
        self:Destroy()
    end,

    OnBlackHoleDissipated = function(self)
        -- fired by the blackhole when we're being sucked up but the black hole dissipates before we're destroyed. Revert back to normal damage thread.
        -- warp to create wreck and damage effects at current (visible) position
        local pos = self:GetPosition(0)
        local ori = self:GetOrientation()
        self.BlackholeSlider:Destroy()
        Warp( self, pos, ori )
        self:OnStopBeingSuckedInBlackhole()
        self:ForkThread( self.DeathThread, self.overkillRatio, nil )
    end,

    OnStartBeingSuckedInBlackhole = function(self, blackhole)
    end,

    OnStopBeingSuckedInBlackhole = function(self)
    end,

    -- ================================================================================================================
    -- ARTILLERY SUPPORT

    OnWeaponSupported = function(self, supportingUnit, weapon, targetPos, target)
        -- A weapon on this unit is supported by another unit
    end,

    OnSupportingArtillery = function(self, artillery, targetPos, target)
        -- This unit supports a weapon on another unit
    end,

    -- ================================================================================================================
    -- INTEL OVERCHARGE

    CanIntelOvercharge = function(self)  -- so all units have this function
        return false
    end,

    -- ================================================================================================================
    -- BOMBARDMENT MODE

    OnBombardmentModeChanged = function( self, enabled, changedByTransport )
    end,

    -- ================================================================================================================
    -- ON WATER SPEED MULTIPLIER
    -- some units have a different speed when submerged. Use AboveWaterFireOnly = true in the weapon BP to disable firing.
    -- Moved from Nomads amphibious units to here per build 41. Ideal place would be in MobileUnit class in defaultunits.lua
    -- but that requires massive rederiving of all classes based on MobileUnit (a lot of work).

    OnLayerChange = function(self, new, old)
        oldUnit.OnLayerChange(self, new, old)
        if new == 'Water' then
            self:OnWater()
        elseif new == 'Sub' or new == 'Seabed' then
            self:OnInWater()
        elseif new == 'Air' then
            self:OnInAir()
        elseif new == 'Land' then
            self:OnLand()
        end
        self:UpdateWeaponLayers(new, old)
    end,

    OnInWater = function(self)
        -- reduce speed
        local BuffName = self:GetBlueprint().Physics.OnInWaterBuff
        if BuffName then
            Buff.ApplyBuff(self, BuffName)
        end
        BuffName = self:GetBlueprint().Physics.OnWaterBuff
        if BuffName then
            Buff.RemoveBuff(self, BuffName, true)
        end
    end,

    OnWater = function(self)
        -- reduce speed
        local BuffName = self:GetBlueprint().Physics.OnWaterBuff
        if BuffName then
            Buff.ApplyBuff(self, BuffName)
        end
        BuffName = self:GetBlueprint().Physics.OnInWaterBuff
        if BuffName then
            Buff.RemoveBuff(self, BuffName, true)
        end
    end,

    OnInAir = function(self)
    end,

    OnLand = function(self)
        -- restore speed
        local BuffName = self:GetBlueprint().Physics.OnWaterBuff
        if BuffName then
            Buff.RemoveBuff(self, BuffName, true)
        end
        BuffName = self:GetBlueprint().Physics.OnInWaterBuff
        if BuffName then
            Buff.RemoveBuff(self, BuffName, true)
        end
    end,

    -- ================================================================================================================
    -- SPECIAL ABILITIES

    RegisterSpecialAbilities = function(self)
        -- registering special abilities at the brain
        local bp = self:GetBlueprint()
        if bp.SpecialAbilities then
            local brain = self:GetAIBrain()
            for abil, abp in bp.SpecialAbilities do
                if not abp.IsRangeExtender then        -- range extender units only extend the range of another unit but can't use the ability
                    local AutoEnable = not ((abp.NoAutoEnable or false) == true)
                    brain:AddSpecialAbilityUnit( self, abil, AutoEnable, true )
                end
                brain:AddSpecialAbilityRangeCheckUnit( self, abil )
            end

            -- if we have counted projectiles then set unit availability based on current ammo
            local bp, wep, IsNuke
            local NumWep = self:GetWeaponCount()
            for i=1, NumWep do
                wep = self:GetWeapon(i)
                bp = wep:GetBlueprint()
                if bp.CountedProjectile == true then
                    if bp.NukeWeapon then
                        self:SpecialAbilitySetAvailability( self:GetNukeSiloAmmoCount() >= 1 )
                    else
                        self:SpecialAbilitySetAvailability( self:GetTacticalSiloAmmoCount() >= 1 )
                    end
                    break
                end
            end
        end
    end,

    UnregisterSpecialAbilities = function(self)
        -- unregistering special abilities at the brain
        local bp = self:GetBlueprint()
        if bp.SpecialAbilities then
            local brain = self:GetAIBrain()
            for abil, abp in bp.SpecialAbilities do
                if not abp.IsRangeExtender then        -- range extender units only extend the range of another unit but can't use the ability
                    brain:RemoveSpecialAbilityUnit( self, abil, true )
                end
                brain:RemoveSpecialAbilityRangeCheckUnit( self, abil )
            end
        end
    end,

    SpecialAbilitySetAvailability = function(self, bool)
        local bp = self:GetBlueprint()
        if bp.SpecialAbilities then
            local brain = self:GetAIBrain()
            for abil, abp in bp.SpecialAbilities do
                brain:SetSpecialAbilityUnitAvailability( self, abil, bool )
            end
        end
    end,

    --Updates build restrictions of any unit passed, used for support factories
    updateBuildRestrictions = function(self)
        local faction = false
        local type = false
        local techlevel = false

        --Defines the unit's faction
        if EntityCategoryContains(categories.AEON, self) then
            faction = categories.AEON
        elseif EntityCategoryContains(categories.UEF, self) then
            faction = categories.UEF
        elseif EntityCategoryContains(categories.CYBRAN, self) then
            faction = categories.CYBRAN
        elseif EntityCategoryContains(categories.SERAPHIM, self) then
            faction = categories.SERAPHIM
        elseif EntityCategoryContains(categories.NOMADS, self) then
            faction = categories.NOMADS
        end

        --Defines the unit's layer type
        if EntityCategoryContains(categories.LAND, self) then
            type = categories.LAND
        elseif EntityCategoryContains(categories.AIR, self) then
            type = categories.AIR
        elseif EntityCategoryContains(categories.NAVAL, self) then
            type = categories.NAVAL
        end

        --Defines the unit's tech level
        if EntityCategoryContains(categories.TECH1, self) then
            techlevel = categories.TECH1
        elseif EntityCategoryContains(categories.TECH2, self) then
            techlevel = categories.TECH2
        elseif EntityCategoryContains(categories.TECH3, self) then
            techlevel = categories.TECH3
        end

        local aiBrain = self:GetAIBrain()
        local supportfactory = false

        --Sanity check.
        if not faction then
            return
        end

        --Add build restrictions
        if EntityCategoryContains(categories.FACTORY, self) then
            if EntityCategoryContains(categories.SUPPORTFACTORY, self) then
                --Add support factory cannot build higher tech units at all, until there is a HQ factory
                self:AddBuildRestriction(categories.TECH2 * categories.MOBILE)
                self:AddBuildRestriction(categories.TECH3 * categories.MOBILE)
                self:AddBuildRestriction(categories.TECH3 * categories.FACTORY)
                supportfactory = true
            else
                --A normal factory cannot build a support factory until there is a HQ factory
                self:AddBuildRestriction(categories.SUPPORTFACTORY)
                supportfactory = false
            end
        elseif EntityCategoryContains(categories.ENGINEER, self) then
            --Engineers also cannot build a support factory until there is a HQ factory
            self:AddBuildRestriction(categories.SUPPORTFACTORY)
        end

        --Check for the existence of HQs
        if supportfactory then
            if not type then
                return
            end

            for id, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH2 * faction, false, true) do
                if not unit.Dead and not unit:IsBeingBuilt() then
                    self:RemoveBuildRestriction(categories.TECH2 * categories.MOBILE * categories.CONSTRUCTION)
                end
            end

            for id, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH3 * faction, false, true) do
                if not unit.Dead and not unit:IsBeingBuilt() then
                    self:RemoveBuildRestriction(categories.TECH2 * categories.MOBILE * categories.CONSTRUCTION)
                    self:RemoveBuildRestriction(categories.TECH3 * categories.MOBILE * categories.CONSTRUCTION)
                    break
                end
            end

            for id, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH2 * faction * type, false, true) do
                if not unit.Dead and not unit:IsBeingBuilt() then
                    self:RemoveBuildRestriction(categories.TECH2 * categories.MOBILE)
                    break
                end
            end

            for id, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH3 * faction * type, false, true) do
                if not unit.Dead and not unit:IsBeingBuilt() then
                    self:RemoveBuildRestriction(categories.TECH2 * categories.MOBILE)
                    self:RemoveBuildRestriction(categories.TECH3 * categories.MOBILE)
                    self:RemoveBuildRestriction(categories.TECH3 * categories.FACTORY * categories.SUPPORTFACTORY)
                    break
                end
            end
        else
            for i,researchType in ipairs({categories.LAND, categories.AIR, categories.NAVAL}) do
                --If there is a research station of the appropriate type, enable support factory construction
                for id, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH2 * faction * researchType, false, true) do
                    if not unit.Dead and not unit:IsBeingBuilt() then
                        --Special case for the Commander, since its engineering upgrades are implemented using build restrictions
                        --In future, figure out a way to query existing legal builds? For example, check if you can build T2, if you can, enable support factory too
                        if EntityCategoryContains(categories.COMMAND, self) then
                            if self:HasEnhancement('AdvancedEngineering') or self:HasEnhancement('T3Engineering') then
                                self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * faction * researchType)
                            end
                        else
                            self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * faction * researchType)
                        end
                        break
                    end
                end

                for id, unit in aiBrain:GetListOfUnits(categories.RESEARCH * categories.TECH3 * faction * researchType, false, true) do
                    if not unit.Dead and not unit:IsBeingBuilt() then

                        --Special case for the commander, since its engineering upgrades are implemented using build restrictions
                        if EntityCategoryContains(categories.COMMAND, self) then
                            if self:HasEnhancement('AdvancedEngineering') then
                                self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * faction * researchType)
                            elseif self:HasEnhancement('T3Engineering') then
                                self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * faction * researchType)
                                self:RemoveBuildRestriction(categories.TECH3 * categories.SUPPORTFACTORY * faction * researchType)
                            end
                        else
                            self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * faction * researchType)
                            self:RemoveBuildRestriction(categories.TECH3 * categories.SUPPORTFACTORY * faction * researchType)
                        end

                        break
                    end
                end
            end
        end
    end,

}

end