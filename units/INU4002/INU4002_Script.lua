-- experimental hover unit bullfrog

local AddBombardModeToUnit = import('/lua/nomadsutils.lua').AddBombardModeToUnit
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
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

NExperimentalHoverLandUnit = AddBombardModeToUnit( NExperimentalHoverLandUnit )

INU4002 = Class(NExperimentalHoverLandUnit, SlowHover) {

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

    OnStopBeingBuilt = function(self,builder,layer)
        NExperimentalHoverLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:ForkThread(self.HeadRotationThread)
    end,

    OnBombardmentModeChanged = function( self, enabled, changedByTransport )
        NExperimentalHoverLandUnit.OnBombardmentModeChanged(self, enabled, changedByTransport)
        self:CalcGattlingRotationSpeed()
        self:ActivateGattlingRotation( self.GattlingCannonActive )
    end,

    CalcGattlingRotationSpeed = function(self)
        local wep = self:GetWeaponByLabel('FrontGun')
        if wep then

            local wepBp = wep:GetBlueprint()
            local rof = wepBp.RateOfFire or 1

            -- check bombardment mode values
            if self.BombardmentMode and wepBp.BombardDisable then
                self.GattlingRotSpeed = 0
                return
            elseif self.BombardmentMode and wepBp.BombardParticipant then
                rof = wep.CurrentROF or rof
            end

            rof = 10 / math.floor( 10 / rof)
            self.GattlingRotSpeed = rof * 120    -- every rof-time turn 120, or one-third (3 barrels)

        else
            self.GattlingRotSpeed = 0
        end
    end,

    ActivateGattlingRotation = function(self, activate)
        self.GattlingCannonActive = (activate == true)
        local m = 0
        if self.GattlingCannonActive then
            m = 1
        end
        self.GattlingManip:SetTargetSpeed( self.GattlingRotSpeed * m )
    end,

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

        while not self:IsDead() do

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

    SetBombardmentMode = function(self, enable, changedByTransport)
        NExperimentalHoverLandUnit.SetBombardmentMode(self, enable, changedByTransport)
        self:SetScriptBit('RULEUTC_WeaponToggle', enable)
    end,

    OnScriptBitSet = function(self, bit)
        NExperimentalHoverLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then
            NExperimentalHoverLandUnit.SetBombardmentMode(self, true, false)
        end
    end,

    OnScriptBitClear = function(self, bit)
        NExperimentalHoverLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then
            NExperimentalHoverLandUnit.SetBombardmentMode(self, false, false)
        end
    end,

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
        local army = self:GetArmy()

        -- Create Initial explosion effects
        explosion.CreateFlash( self, 'INU4002', 2, army )
        CreateAttachedEmitter(self, 'INU4002', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(0.5)
        CreateAttachedEmitter(self, 'INU4002', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp')
        CreateAttachedEmitter(self, 'INU4002', army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.5)
        self:ShakeCamera(50, 5, 0, 1)

        self:CreateExplosionDebris( 'INU4002', army )
        self:CreateExplosionDebris( 'INU4002', army )

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
            self:CreateExplosionDebris( bone, army )
            WaitTicks( 13 - i - Random(0, 3) )
        end

        -- final explosion
        explosion.CreateFlash( self, 'INU4002', 3, army )
        self:ShakeCamera(3, 2, 0, 0.15)
        self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris( 'INU4002', army )
        self:CreateExplosionDebris( 'INU4002', army )

        -- Finish up force ring to push trees
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        -- create wreckage
        if leaveWreckage then
            self:CreateWreckage(overkillRatio)
        end

        self:Destroy()
    end,

    DeathExplosionsOnWaterThread = function( self, overkillRatio, instigator)
        self:DeathExplosionsThread(overkillRatio, instigator, true )
    end,

    CreateExplosionDebris = function( self, bone, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
}

TypeClass = INU4002
