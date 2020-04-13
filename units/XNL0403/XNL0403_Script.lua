-- experimental hover unit crawler

local AddLights = import('/lua/nomadsutils.lua').AddLights
local NExperimentalHoverLandUnit = import('/lua/nomadsunits.lua').NExperimentalHoverLandUnit
local NomadsWeaponsFile = import('/lua/nomadsweapons.lua')
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1
local MissileWeapon1 = NomadsWeaponsFile.MissileWeapon1
local GattlingWeapon1 = NomadsWeaponsFile.GattlingWeapon1
local StrategicMissileWeapon = import('/lua/nomadsweapons.lua').StrategicMissileWeapon
local ParticleBlaster1 = NomadsWeaponsFile.ParticleBlaster1

local explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local GetRandomInt = import('/lua/utilities.lua').GetRandomInt
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

XNL0403 = Class(NExperimentalHoverLandUnit, SlowHover) {

    Weapons = {
        MainGun = Class(TacticalMissileWeapon1) {},
        NukeMissiles = Class(StrategicMissileWeapon) {

            OnCreate = function(self)
                StrategicMissileWeapon.OnCreate(self)
                self.CurrentROF = self:GetBlueprint().RateOfFire or 1
            end,

            OnWeaponFired = function(self)
                StrategicMissileWeapon.OnWeaponFired(self)
            end,

            ChangeRateOfFire = function(self, value)
                -- modified to store the rate of fire
                StrategicMissileWeapon.ChangeRateOfFire(self, value)
                self.CurrentROF = value
            end,

            SetWeaponEnabled = function(self, enable)
                StrategicMissileWeapon.SetWeaponEnabled(self, enable)
            end,
        },
        FrontGattling01 = Class(GattlingWeapon1) {},
        FrontGattling02 = Class(GattlingWeapon1) {},
        SideGunRight01 = Class(ParticleBlaster1) {},
        SideGunRight02 = Class(ParticleBlaster1) {},
        SideGunLeft01 = Class(ParticleBlaster1) {},
        SideGunLeft02 = Class(ParticleBlaster1) {},
        AAGun = Class(MissileWeapon1) {},
    },

    LightBones = {
        { 'flash_R.001', 'flash_L.001', },
        { 'flash_R.002', 'flash_L.002', },
        { 'flash_R.003', 'flash_L.003', },
        { 'flash_R.004', 'flash_L.004', },
        { 'flash_R.005', 'flash_L.005', },
        { 'flash_R.006', 'flash_L.006', },
    },
    SmokeEmitterBones = {
        'smoke.001',
        'smoke.002',
        'smoke.003',
        'smoke.004',
    },

    OnCreate = function(self)
        NExperimentalHoverLandUnit.OnCreate(self)
        self.SmokeEmitters = TrashBag()
		self.NukeEntity = 1 
    end,

    OnDestroy = function(self)
        self:DestroyMovementSmokeEffects()
        NExperimentalHoverLandUnit.OnDestroy(self)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NExperimentalHoverLandUnit.OnStopBeingBuilt(self, builder, layer)
        self:PlayMovementSmokeEffects('Stopped')
    end,

    OnDetachedToTransport = function(self, transport)
    end,


-- EFFECTS =====================

    OnMotionHorzEventChange = function( self, new, old )
        NExperimentalHoverLandUnit.OnMotionHorzEventChange( self, new, old )

        -- blow smoke from the vents
        if new ~= old then
            self:DestroyMovementSmokeEffects()
            self:PlayMovementSmokeEffects(new)
        end
    end,

    PlayMovementSmokeEffects = function(self, type)
        local EffectTable, emit

        if type == 'Stopping' then
            EffectTable = NomadsEffectTemplate.HoverEffect_Stopping_Smoke
        elseif type == 'Stopped' then
            EffectTable = NomadsEffectTemplate.HoverEffect_Stopped_Smoke
        else
            EffectTable = NomadsEffectTemplate.HoverEffect_Moving_Smoke
        end

        for _, bone in self.SmokeEmitterBones do
            for k, v in EffectTable do
                emit = CreateAttachedEmitter( self, bone, self.Army, v )
                self.SmokeEmitters:Add( emit )
                self.Trash:Add( emit )
            end
        end
    end,

    DestroyMovementSmokeEffects = function(self)
        self.SmokeEmitters:Destroy()
    end,

-- DYING =====================

    CrushDuringDescent = function(self)
        -- This is a WOF event which is in here cause I like WOF! Sorry, I can't be crushed during sinking!
        return false
    end,

    OnSeabedImpact = function( self)
        -- This is a WOF event which is in here cause I like WOF! Trigger unit death explosion
        if not self.WOF_OnSeabedImpact_Flag then
            self.WOF_OnSeabedImpact_Flag = true
            self:WOF_DoSurfaceImpactWeapon( 'Seabed', false )
            self:ForkThread( self.DeathExplosionsThread, self:GetOverKill(), true )
        end
    end,

    DeathThread = function( self, overkillRatio, instigator)
        -- I'm concerned what happens if this unit dies while hover on the water surface. The unit should not leave a corpse.
        -- If WOF is available the unit cloud/should sink to the bottom under the WOF effect.

        if self:GetCurrentLayer() ~= 'Water' then
            -- We're not on water. Just explode a leave a wreck, no problemo
            self:DeathExplosionsThread( overkillRatio, instigator, true )
        else
            local WOFavailble = ( self.WOF_DoSink ~= nil)
            if WOFavailble then
                -- if WOF is available let it handle us sinking
                NExperimentalHoverLandUnit.DeathThread( self, overkillRatio, instigator)
            else
                -- else, get killed on water and don't leave a corpse
                self:DeathExplosionsOnWaterThread( overkillRatio, instigator )
            end
        end
    end,

    DeathExplosionsThread = function( self, overkillRatio, instigator, leaveWreckage)
        -- slightly inspired by the monkeylords effect

        self:PlayUnitSound('Killed')

        -- Create Initial explosion effects
        explosion.CreateFlash( self, 'TML.003', 2, self.Army )
        CreateAttachedEmitter(self, 0, self.Army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(0.5)
        CreateAttachedEmitter(self, 0, self.Army, '/effects/emitters/explosion_fire_sparks_02_emit.bp')
        CreateAttachedEmitter(self, 0, self.Army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.5)
        self:ShakeCamera(50, 5, 0, 1)

        self:CreateExplosionDebris( 0, self.Army )
        self:CreateExplosionDebris( 0, self.Army )

        -- damage ring to push trees
        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        -- cancel unit hovering
        self:SetElevation(0)
        self:DestroyMovementEffects()
        self:DestroyIdleEffects()

        WaitTicks( Random(3, 6) )

        -- some more explosions
        local numBones = self:GetBoneCount() - 1
        for i=Random(1,3), 8 do
            local bone = Random( 0, numBones )
            explosion.CreateDefaultHitExplosionAtBone( self, bone, GetRandomInt( 1.0, 4.0) )
            self:CreateExplosionDebris( bone, self.Army )
            WaitTicks( 13 - i - Random(0, 3) )
        end

        -- final explosion
        explosion.CreateFlash( self, 0, 3, self.Army )
        self:ShakeCamera(3, 2, 0, 0.15)
        self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris( 0, self.Army )
        self:CreateExplosionDebris( 0, self.Army )

        -- Finish up force ring to push trees
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        -- create wreckage
        if leaveWreckage then
            self:CreateWreckage( overkillRatio )
        end

        self:Destroy()
    end,

    DeathExplosionsOnWaterThread = function( self, overkillRatio, instigator)
        self:DeathExplosionsThread(overkillRatio, instigator, false )
    end,

    CreateExplosionDebris = function( self, bone, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
}

TypeClass = XNL0403
