local NomadsWeaponsFile = import('/lua/nomadsweapons.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local explosion = import('/lua/defaultexplosions.lua')
local NExperimentalHoverLandUnit = import('/lua/nomadsunits.lua').NExperimentalHoverLandUnit
local GetRandomInt = import('/lua/utilities.lua').GetRandomInt
local SlowHoverLandUnit = import('/lua/defaultunits.lua').SlowHoverLandUnit

local MissileWeapon1 = NomadsWeaponsFile.MissileWeapon1
local GattlingWeapon1 = NomadsWeaponsFile.GattlingWeapon1
local TacticalMissileWeapon1 = NomadsWeaponsFile.TacticalMissileWeapon1
local StrategicMissileWeapon = NomadsWeaponsFile.StrategicMissileWeapon

--- Experimental Hover Crawler
---@class XNL0403 : NExperimentalHoverLandUnit, SlowHoverLandUnit
XNL0403 = Class(NExperimentalHoverLandUnit, SlowHoverLandUnit) {

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

    ---@param self XNL0403
    OnCreate = function(self)
        NExperimentalHoverLandUnit.OnCreate(self)
        self.SmokeEmitters = TrashBag()
		self.NukeEntity = 1
    end,

    ---@param self XNL0403
    OnDestroy = function(self)
        self:DestroyMovementSmokeEffects()
        NExperimentalHoverLandUnit.OnDestroy(self)
    end,

    ---@param self XNL0403
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self, builder, layer)
        NExperimentalHoverLandUnit.OnStopBeingBuilt(self, builder, layer)
        self:PlayMovementSmokeEffects('Stopped')
    end,

    ---@param self XNL0403
    ---@param transport Unit
    OnDetachedToTransport = function(self, transport)
    end,

    ---@param self XNL0403
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
    OnMotionHorzEventChange = function( self, new, old )
        NExperimentalHoverLandUnit.OnMotionHorzEventChange( self, new, old )

        -- blow smoke from the vents
        if new ~= old then
            self:DestroyMovementSmokeEffects()
            self:PlayMovementSmokeEffects(new)
        end
    end,

    ---@param self XNL0403
    ---@param damageType DamageType unused
    PlayMovementSmokeEffects = function(self, damageType)
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

    ---@param self XNL0403
    DestroyMovementSmokeEffects = function(self)
        self.SmokeEmitters:Destroy()
    end,

    --- This is a WOF event which is in here cause I like WOF! Sorry, I can't be crushed during sinking!
    ---@param self XNL0403
    ---@return boolean|false
    CrushDuringDescent = function(self)
        return false
    end,

    ---@param self XNL0403
    OnSeabedImpact = function( self)
        -- This is a WOF event which is in here cause I like WOF! Trigger unit death explosion
        if not self.WOF_OnSeabedImpact_Flag then
            self.WOF_OnSeabedImpact_Flag = true
            self:WOF_DoSurfaceImpactWeapon( 'Seabed', false )
            self:ForkThread( self.DeathExplosionsThread, self:GetOverKill(), true )
        end
    end,

    --- I'm concerned what happens if this unit dies while hover on the water surface. The unit should not leave a corpse.
    --- If WOF is available the unit cloud/should sink to the bottom under the WOF effect.
    ---@param self XNL0403
    ---@param overkillRatio number
    ---@param instigator Unit
    DeathThread = function( self, overkillRatio, instigator)
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

    ---@param self XNL0403
    ---@param overkillRatio number
    ---@param instigator Unit unused
    ---@param leaveWreckage boolean
    DeathExplosionsThread = function( self, overkillRatio, instigator, leaveWreckage)
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

    ---@param self XNL0403
    ---@param overkillRatio number
    ---@param instigator Unit
    DeathExplosionsOnWaterThread = function( self, overkillRatio, instigator)
        self:DeathExplosionsThread(overkillRatio, instigator, false )
    end,

    ---@param self XNL0403
    ---@param bone Bone
    ---@param army Army
    CreateExplosionDebris = function( self, bone, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
}
TypeClass = XNL0403