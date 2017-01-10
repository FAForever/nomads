do

local oldUnit = Unit

Unit = Class(oldUnit) {

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

    OnKilled = function(self, instigator, type, overkillRatio)
        self:UnregisterSpecialAbilities()
        if self:DoOnKilledByBlackhole(type) then
            self:OnKilledByBlackHole(instigator, type, overkillRatio)
        else
            oldUnit.OnKilled(self, instigator, type, overkillRatio)
        end
    end,

    -- Bug fix for GPG 3599 and 3603 code. The original DeathThread function calls this function. It does this in this way:
    -- self:CreateDestructionEffects( self, overkillRatio )
    -- The variable "self" is used as the overkillRatio parameter. The overkill variable is passed as the third parameter which isn't
    -- specified in the function declaration. Removing the second "self" fixes the problem. Unfortunately this can only be done
    -- destructively, or so it seems.
    DeathThread = function( self, overkillRatio, instigator)

        WaitSeconds( utilities.GetRandomFloat( self.DestructionExplosionWaitDelayMin, self.DestructionExplosionWaitDelayMax) )
        self:DestroyAllDamageEffects()

        if self.PlayDestructionEffects then
            self:CreateDestructionEffects( overkillRatio )  -- removed "self" as first parameter
        end

        --MetaImpact( self, self:GetPosition(), 0.1, 0.5 )
        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
            if self.PlayDestructionEffects and self.PlayEndAnimDestructionEffects then
                self:CreateDestructionEffects( overkillRatio )  -- removed "self" as first parameter
            end
        end

        self:CreateWreckage( overkillRatio )

        if( self.ShowUnitDestructionDebris and overkillRatio ) then
            if overkillRatio <= 1 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 2 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 3 then
                self.CreateUnitDestructionDebris( self, true, true, true )
            else --VAPORIZED
                self.CreateUnitDestructionDebris( self, true, true, true )
            end
        end

        WaitSeconds(self.DeathThreadDestructionWaitTime)

        self:PlayUnitSound('Destroyed')
        self:Destroy()
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
                while self and not self:IsDead() do
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
                    targets = utilities.GetUnitsInSphere(PosEntity, buffTable.Radius)
                else
                    targets = utilities.GetEnemyUnitsInSphere(self, PosEntity, buffTable.Radius)
                end
            else
                if buffTable.ApplyToFriendly then
                    targets = utilities.GetUnitsInSphere(self:GetPosition(), buffTable.Radius)
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
            self:DisableUnitIntel()
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
            self:EnableUnitIntel()
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
            return self.MyShield.IsPersonalShield or false
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

    DoOnKilledByBlackhole = function(self, DmgType)
        if DmgType == 'BlackholeDamage' or DmgType == 'BlackholeDeathNuke' then
            return true
        end
        return false
    end,

    OnKilledByBlackHole = function(self, instigator, type, overkillRatio)
        if self:DoOnKilledByBlackhole(type) then

            if self._IsSuckedInBlackHole then return end

            -- if killed by a black hole then do a special animation.
            -- this is a shortened version of the stock onkilled event
            self.Dead = true
            self.overkillRatio = overkillRatio
            self:SetCollisionShape('None')
            self:DoUnitCallbacks( 'OnKilled' )

            self:DestroyAllDamageEffects()
            self:DestroyTopSpeedEffects()
            self:DestroyMovementEffects()
            self:DestroyIdleEffects()

            self:DisableShield()
            self:DisableUnitIntel()

            if self.TarmacBag then
                self:DestroyTarmac()
            end

            if self.UnitBeingTeleported and not self.UnitBeingTeleported:IsDead() then
                self.UnitBeingTeleported:Destroy()
                self.UnitBeingTeleported = nil
            end
            if instigator then
                if IsUnit(instigator) or instigator.OnKilledUnit then
                    instigator:OnKilledUnit(self)
                end
            end
            self:ForkThread(self.DeathThreadBlackHole, instigator)
        end
    end,

    IsSuckedInBlackHole = function(self)
        return self._IsSuckedInBlackHole or false
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

    OnKilledByBlackhole = function(self, blackhole)
        -- destroy unit without further effects. Matter, light and sounds are sucked in so we're done here
        self:Destroy()
    end,

    OnStopBeingSuckedInBlackhole = function(self)
    end,

    DeathThreadBlackHole = function( self, instigator )
        self._IsSuckedInBlackHole = true

        local Utilities = import('/lua/utilities.lua')

        -- This is a bit complex. The slider used below uses a relative direction. To feed the correct destinations to the slider
        -- we need to calculate the angle of the black hole relative to the unit, the units angle on the world map and the distance
        -- to the black hole.

        -- distance to black hole
        local pos = self:GetPosition()
        local HolePos = instigator:GetPosition()
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
        self.BlackholeSlider:SetSpeed(35)
        self.BlackholeSlider:SetWorldUnits(true)
        self.Trash:Add( self.BlackholeSlider )

        self:OnStartBeingSuckedInBlackhole(instigator)

        -- let black hole know we're being sucked in
        if instigator.OnUnitBeingSuckedIn then
            instigator:OnUnitBeingSuckedIn(self)
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
        if instigator.OnUnitSuckedIn then
            instigator:OnUnitSuckedIn(self, self.overkillRatio)
        end

        self:OnKilledByBlackhole(instigator)
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
}

end