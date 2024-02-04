do

local oldUnit = Unit
local colourslist = import('/lua/GameColors.lua').GameColors.ArmyColors
local DetermineColourIndex = import('/lua/NomadsUtils.lua').DetermineColourIndex
--local CreateAttachedEmitter = import('/lua/NomadsUtils.lua').CreateAttachedEmitterColoured
local Factions = import('/lua/factions.lua').GetFactions(true)

Unit = Class(oldUnit) {

    -- ================================================================================================================
    -- improved emitter features
    --we add the functionality to change the colour of emitters based on the units faction colour.
    --this is done via a specially made shader that takes the ramp selection curve and applies a colour based on that.
    --we then use SetEmitterCurveParam to change the colour via scripts
    --for beams and trails, there is no direct way to pass the index via scripts, so we create a set of duplicate blueprints for them and swap them out at beam/trail creation time.

    OnPreCreate = function(self)
    --we determine the index once on create then save it in the entity table to save on sim slowdown
        if not self.ColourIndex then
            local hexColour = colourslist[ScenarioInfo.ArmySetup[ListArmies()[self:GetArmy()]].ArmyColor]
            self.ColourIndex = DetermineColourIndex(hexColour)
        end

        oldUnit.OnPreCreate(self)
    end,

    CreateTerrainTypeEffects = function( self, effectTypeGroups, FxBlockType, FxBlockKey, TypeSuffix, EffectBag, TerrainType )
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
                WARN('*WARNING: No effect bones defined for layer group ',repr(self.UnitId),', Add these to a table in Display.[EffectGroup].', self:GetCurrentLayer(), '.Effects { Bones ={} } in unit blueprint.' )
            else
                for kb, vBone in vTypeGroup.Bones do
                    for ke, vEffect in effects do
                        emit = CreateAttachedEmitter(self,vBone,self.Army,vEffect):ScaleEmitter(vTypeGroup.Scale or 1)
                        if vTypeGroup.Offset then
                            emit:OffsetEmitter(vTypeGroup.Offset[1] or 0, vTypeGroup.Offset[2] or 0,vTypeGroup.Offset[3] or 0)
                        end
                        if vTypeGroup.Recolour then
                            emit:SetEmitterCurveParam('RAMPSELECTION_CURVE', self.ColourIndex, 0)
                        end
                        if EffectBag then
                            table.insert( EffectBag, emit )
                        end
                    end
                end
            end
        end
    end,

    OnCreate = function(self)
        oldUnit.OnCreate(self)
        self._IsSuckedInBlackHole = false
        
        --TODO: remove these once FAF merges in the relevant PR
        self.Army = self:GetArmy()
        self.Sync.army = self.Army
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        oldUnit.OnStopBeingBuilt(self, builder, layer)
        self:RegisterSpecialAbilities()
        self:MonitorAmmoCount()
    end,

    OnDestroy = function(self)
        if self.AbilitiesCleared ~= true then
            self:UnregisterSpecialAbilities()
        end
        self.AbilitiesCleared = nil --just in case its not cleared
        oldUnit.OnDestroy(self)
    end,

    -- ================================================================================================================
    -- AMMO EVENTS

    TacMissileCreatedAtUnit = function(self)
        -- when the unit launches a counted tactical missile.
    end,

    GiveNukeSiloAmmo = function(self, count)
        oldUnit.GiveNukeSiloAmmo(self, count)
        --self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchNuke', {AvailableNowUnit = self:GetNukeSiloAmmoCount(),})
        self:SetSpecialAbilityAvailability('LaunchNuke', self:GetNukeSiloAmmoCount())
    end,

    GiveTacticalSiloAmmo = function(self, count)
        oldUnit.GiveTacticalSiloAmmo(self, count)
        --self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchTacMissile', {AvailableNowUnit = self:GetTacticalSiloAmmoCount(),})
        self:SetSpecialAbilityAvailability('LaunchTacMissile', self:GetTacticalSiloAmmoCount())
    end,

    RemoveNukeSiloAmmo = function(self, count)
        oldUnit.RemoveNukeSiloAmmo(self, count)
        --self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchNuke', {AvailableNowUnit = self:GetNukeSiloAmmoCount(),})
        self:SetSpecialAbilityAvailability('LaunchNuke', self:GetNukeSiloAmmoCount())
    end,

    RemoveTacticalSiloAmmo = function(self, count)
        oldUnit.RemoveTacticalSiloAmmo(self, count)
        --self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchTacMissile', {AvailableNowUnit = self:GetTacticalSiloAmmoCount(),})
        self:SetSpecialAbilityAvailability('LaunchTacMissile', self:GetTacticalSiloAmmoCount())
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
                    local AbilityName = 'LaunchTacMissile'
                    if nuke then
                        new = self:GetNukeSiloAmmoCount()
                        AbilityName = 'LaunchNuke'
                    else
                        new = self:GetTacticalSiloAmmoCount()
                    end
                    if new > old then
                        --self:GetAIBrain():SetUnitSpecialAbility(self, AbilityName, {AvailableNowUnit = new,})
                        self:SetSpecialAbilityAvailability(AbilityName, new)
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
    
    --Copy EQ (and improve!) transport animation fix; we need it for getting the beamer to always work properly.
    
    --We set up flags so the unit knows when its inside a transport or not
    OnAttachedToTransport = function(self, transport, bone)
        self.InTransport = true --EQ: flag for in transport units
        oldUnit.OnAttachedToTransport(self, transport, bone)
    end,

    OnDetachedFromTransport = function(self, transport, bone)
        self.InTransport = nil
        oldUnit.OnDetachedFromTransport(self, transport, bone)
    end,
    
    OnStopTransportBeamUp = function(self)
        oldUnit.OnStopTransportBeamUp(self)
        --EQ: if the transport command gets cancelled we need to cancel and remove the animation as well.
        self:ForkThread(self.TransportBeamThread)
    end,
    
    TransportBeamThread = function(self)
        WaitTicks(10)--OnAttachedToTransport is called after this so we need a delay
        if not self.InTransport and self.TransAnimation and self.TransAnimThread then
            KillThread(self.TransAnimThread)
            self.TransAnimation:Destroy()
            self.TransAnimation = nil
        end
    end,
    
    -- EQ: we store this in a variable so the thread can be killed, instead of as a function
    TransportAnimation = function(self, rate)
        self.TransAnimThread = self:ForkThread(self.TransportAnimationThread, rate)
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
        if val then
            if val < 1 then
                val = math.sqrt(val)
            end
        else
            WARN('Nomads: SetSpeedMult: Can\'t set SpeedMult to unit ['..repr(self.UnitId or "Unknown")..']. val=nil!')
            return
        end
        return oldUnit.SetSpeedMult(self, val)
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
                self:OnStunnedOver(self)
            end
            if self.StunnedThread then  -- if unit it hit twice by stun weapon then this ensures the second hit prolongs the stun
                KillThread( self.StunnedThread )
                self.StunnedThread = nil
            end
            self.StunnedThread = self:ForkThread(fn, duration)
            self:OnStunned(duration)
            return oldUnit.SetStunned(self, duration) or true
        end
        return false
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
        self.AbilitiesCleared = true
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
        local target = HolePos
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
    -- SPECIAL ABILITIES
    
    RegisterSpecialAbilities = function(self)
        -- registering special abilities at the brain
        local bp = self:GetBlueprint()
        if bp.SpecialAbilities then
            local brain = self:GetAIBrain()
            for abilityName, abilityBp in bp.SpecialAbilities do
                brain:SetUnitSpecialAbility(self, abilityName, abilityBp)
            end
        end
    end,

    UnregisterSpecialAbilities = function(self)
        -- unregistering special abilities at the brain
        local bp = self:GetBlueprint()
        if bp.SpecialAbilities then
            local brain = self:GetAIBrain()
            for abilityName, abilityBp in bp.SpecialAbilities do
                brain:SetUnitSpecialAbility(self, abilityName, 'Remove')
            end
        end
    end,

    --why does this loop through all the abilities of a unit and set them to the same thing?
    SetSpecialAbilityAvailability = function(self, AbilityName, Availability)
        local bp = self:GetBlueprint()
        if bp.SpecialAbilities and bp.SpecialAbilities[AbilityName]then
            self:GetAIBrain():SetUnitSpecialAbility(self, AbilityName, {AvailableNowUnit = Availability,})
        else
            WARN('Nomads: SetSpecialAbilityAvailability called with ability name that isnt in the unit blueprint: '..(tostring(AbilityName or 'nil')))
        end
    end,

}

end