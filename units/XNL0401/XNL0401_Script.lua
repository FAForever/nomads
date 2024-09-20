-- experimental hover unit bullfrog

local NExperimentalHoverLandUnit = import('/lua/nomadsunits.lua').NExperimentalHoverLandUnit
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon
local AnnihilatorCannon1 = import('/lua/nomadsweapons.lua').AnnihilatorCannon1
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1
local KineticCannon1 = import('/lua/nomadsweapons.lua').KineticCannon1
local EffectUtils = import('/lua/effectutilities.lua')
local explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local GetRandomInt = import('/lua/utilities.lua').GetRandomInt
local Utilities = import('/lua/utilities.lua')
local SlowHoverLandUnit = import('/lua/defaultunits.lua').SlowHoverLandUnit


--- Experimental Land Bullfrog
---@class XNL0401 : NExperimentalHoverLandUnit, SlowHoverLandUnit
XNL0401 = Class(NExperimentalHoverLandUnit, SlowHoverLandUnit) {

    Weapons = {
        FrontGun = Class(AnnihilatorCannon1) {

            OnCreate = function(self)
                AnnihilatorCannon1.OnCreate(self)
                self.CurrentROF = self:GetBlueprint().RateOfFire or 1
            end,

            PlayFxWeaponUnpackSequence = function(self)
                self.unit:ActivateGattlingRotation(true)
                self.unit.AllowHeadRotation = false
                AnnihilatorCannon1.PlayFxWeaponPackSequence(self)
            end,

            PlayFxRackSalvoChargeSequence = function(self)
                self.unit:ActivateGattlingRotation(true)
                self.unit.AllowHeadRotation = false
                AnnihilatorCannon1.PlayFxRackSalvoChargeSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                self.unit:ActivateGattlingRotation(false)
                self.unit.AllowHeadRotation = true
                AnnihilatorCannon1.PlayFxWeaponPackSequence(self)
            end,

            PlayFxRackSalvoReloadSequence = function(self)
                self.unit:ActivateGattlingRotation(true)
                self.unit.AllowHeadRotation = false
                AnnihilatorCannon1.PlayFxRackSalvoChargeSequence(self)
            end,

            ChangeRateOfFire = function(self, value)
                -- modified to store the rate of fire
                AnnihilatorCannon1.ChangeRateOfFire(self, value)
                self.CurrentROF = value
            end,
        },
        MainGun = Class(PlasmaCannon) {},
        SideGunLeft = Class(KineticCannon1) {},
        SideGunRight = Class(KineticCannon1) {},
        AAGunLeft = Class(ParticleBlaster1) {},
        AAGunRight = Class(ParticleBlaster1) {},
    },

    ---@param self XNL0401
    OnCreate = function(self)
        NExperimentalHoverLandUnit.OnCreate(self)

        self:CalcGattlingRotationSpeed()

        -- direction rotators
        self.AllowHeadRotation = true
        local bone = self:GetWeaponByLabel('FrontGun'):GetBlueprint().TurretBoneYaw or 'FrontTurret_Yaw'

        self.GattlingManip = CreateRotator(self, 'FrontTurret_Barrels', 'z', nil, self.GattlingRotSpeed, self.GattlingRotSpeed * 10, self.GattlingRotSpeed)
        self.HeadRotManip = CreateRotator(self, bone, 'y', nil):SetCurrentAngle(0)
        self.LeftJetManip = CreateRotator(self, 'Jet_LeftRear', 'y', nil):SetCurrentAngle(0)
        self.RightJetManip = CreateRotator(self, 'Jet_RightRear', 'y', nil):SetCurrentAngle(0)

        self.Trash:Add(self.GattlingManip)
        self.Trash:Add(self.HeadRotManip)
        self.Trash:Add(self.LeftJetManip)
        self.Trash:Add(self.RightJetManip)

        self:ActivateGattlingRotation(false)
    end,

    ---@param self XNL0401
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        NExperimentalHoverLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread(self.HeadRotationThread)
    end,

    ---@param self XNL0401
    CalcGattlingRotationSpeed = function(self)
        local wep = self:GetWeaponByLabel('FrontGun')
        if wep then

            local wepBp = wep:GetBlueprint()
            local rof = wepBp.RateOfFire or 1

            rof = 10 / math.floor( 10 / rof)
            self.GattlingRotSpeed = rof * 120    -- every rof-time turn 120, or one-third (3 barrels)

        else
            self.GattlingRotSpeed = 0
        end
    end,

    ---@param self XNL0401
    ---@param activate boolean
    ActivateGattlingRotation = function(self, activate)
        self.GattlingCannonActive = (activate == true)
        local m = 0
        if self.GattlingCannonActive then
            m = 1
        end
        self.GattlingManip:SetTargetSpeed( self.GattlingRotSpeed * m )
    end,

    ---@param self XNL0401
    HeadRotationThread = function(self)
        -- keeps the head rotated to the current target position

        local nav = self:GetNavigator()
        local wep = self:GetWeaponByLabel('FrontGun')
        local maxRotHead = wep:GetBlueprint().TurretYawRange or 30
        local rotSpeedHead = wep:GetBlueprint().TurretYawSpeed or 50
        local maxRotJet = 10
        local rotSpeedJet = self:GetBlueprint().Display.MovementEffects.JetRotationMax or 60
        local angle, headAngle, jetAngle = 0, 0, 0
        local target, targetPos, pos, navTar

        local CalcAngle = function(self, targetPos, maxAngle)
            local MyPos = self:GetPosition()
            targetPos.y = 0
            targetPos.x = targetPos.x - MyPos.x
            targetPos.z = targetPos.z - MyPos.z
            targetPos = Utilities.NormalizeVector(targetPos)
            local angle = ((math.atan2(targetPos.x, targetPos.z) - self:GetHeading()) * 180 / math.pi)
            if angle > 180 then
                angle = angle - 360
            elseif angle < -180 then
                angle = angle + 360
            end
            local angle = math.max(-maxAngle, math.min(angle, maxAngle))
            return angle
        end

        while not self.Dead do

            target = wep:GetCurrentTarget()
            targetPos = wep:GetCurrentTargetPos()
            navTar = nav:GetCurrentTargetPos()
            pos = self:GetPosition()
            if target and target.GetPosition then
                headAngle = CalcAngle( self, target:GetPosition(), maxRotHead )
            elseif targetPos then
                headAngle = CalcAngle( self, targetPos, maxRotHead )
            else
                headAngle = CalcAngle( self, navTar, maxRotHead )
            end

            if VDist2( pos[1], pos[3], navTar[1], navTar[3] ) > 6 then
                jetAngle = -1 * math.max(-maxRotJet, math.min(maxRotJet, headAngle))
            else
                jetAngle = 0
                headAngle = 0
            end

            if self.AllowHeadRotation then
                self.HeadRotManip:SetSpeed(rotSpeedHead):SetGoal(headAngle)
            end
            self.LeftJetManip:SetSpeed(rotSpeedJet):SetGoal(jetAngle)
            self.RightJetManip:SetSpeed(rotSpeedJet):SetGoal(jetAngle)

            WaitSeconds(0.2)
        end
    end,

    ---@param self XNL0401 unused
    ---@return boolean
    CrushDuringDescent = function(self)
        -- This is a WOF event which is in here cause I like WOF! Sorry, I can't be crushed during sinking!
        return false
    end,

    ---@param self XNL0401
    OnSeabedImpact = function( self)
        -- This is a WOF event which is in here cause I like WOF! Trigger unit death explosion
        if not self.WOF_OnSeabedImpact_Flag then
            self.WOF_OnSeabedImpact_Flag = true
            self:WOF_DoSurfaceImpactWeapon( 'Seabed', false )
            self:ForkThread( self.DeathExplosionsThread, self:GetOverKill(), true )
        end
    end,

    ---@param self XNL0401
    ---@param overkillRatio number
    ---@param instigator Unit
    DeathThread = function( self, overkillRatio, instigator)
        -- I'm concerned what happens if this unit dies while hover on the water surface. The unit should not leave a corpse.
        -- If WOF is available the unit cloud/should sink to the bottom under the WOF effect.

        if self:GetCurrentLayer() ~= 'Water' then
            -- We're not on water. Just explode a leave a wreck, no problemo
            self:DeathExplosionsThread( overkillRatio, instigator, true )
        else
            -- this should be more spectacular!
            self:DeathExplosionsOnWaterThread( overkillRatio, instigator )
            NExperimentalHoverLandUnit.DeathThread( self, overkillRatio, instigator)
        end
    end,

    ---@param self XNL0401
    ---@param overkillRatio number
    ---@param instigator Unit unused
    ---@param leaveWreckage boolean
    DeathExplosionsThread = function( self, overkillRatio, instigator, leaveWreckage)
        -- slightly inspired by the monkeylords effect

        self:PlayUnitSound('Killed')

        -- Create Initial explosion effects
        explosion.CreateFlash( self, 0, 2, self.Army )
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
            self:CreateWreckage(overkillRatio)
            self:Destroy()
        end
    end,

    ---@param self XNL0401
    ---@param overkillRatio number
    ---@param instigator Unit
    DeathExplosionsOnWaterThread = function( self, overkillRatio, instigator)
        self:DeathExplosionsThread(overkillRatio, instigator, false )
    end,

    ---@param self XNL0401
    ---@param bone Bone
    ---@param army Army
    CreateExplosionDebris = function( self, bone, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
}

TypeClass = XNL0401
