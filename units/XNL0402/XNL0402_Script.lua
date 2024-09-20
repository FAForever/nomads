-- experimental beam tank

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local NDFPlasmaBeamWeapon = import('/lua/nomadsweapons.lua').NDFPlasmaBeamWeapon
local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local NomadsUtils = import('/lua/nomadsutils.lua')
local RenameBeamEmitterToColoured = NomadsUtils.RenameBeamEmitterToColoured
local CreateAttachedEmitterColoured = NomadsUtils.CreateAttachedEmitterColoured
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair
local AddRapidRepairToWeapon = import('/lua/nomadsutils.lua').AddRapidRepairToWeapon

NLandUnit = AddRapidRepair(NLandUnit)

--- Experimental Land Beam Tank
---@class XNL0402 : NLandUnit
XNL0402 = Class(NLandUnit) {

    EngineBones = {'RearEngine01', 'RearEngine02', 'RearEngine11', 'RearEngine12', 'FrontEngineBlock01', 'FrontEngineBlock02'},
    FactionColour = true, --allow emitters to be recoloured on this unit

    Weapons = {
        MainGun = Class(AddRapidRepairToWeapon(NDFPlasmaBeamWeapon)) {},
    },

    ---@param self XNL0402
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self.Beaming = false
        self.BeamChargeUpFxBag = TrashBag()
        self.BeamHelperFxBag = TrashBag()
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self):PlayAnim('/units/XNL0402/XNL0402_Charge.sca'):SetRate(0)
            self.Trash:Add(self.AnimationManipulator)
        end
    end,

    ---@param self XNL0402
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        NLandUnit.OnStopBeingBuilt(self,builder,layer)

        if not self.ActivationManipulator then
            self.ActivationManipulator = CreateAnimator(self):PlayAnim(self.Blueprint.Display.AnimationActivate):SetRate(0.3)
            self.Trash:Add(self.ActivationManipulator)
            
            self:ForkThread(function()
                for i=1,15 do --we have to do this dumb thing because hover units have their elevation set instantly
                    WaitTicks(2)
                    self:SetElevation(0.02*i)
                end
                WaitFor(self.ActivationManipulator)
                self.ActivationManipulator:Destroy()
            end)
        end

        self.EngineRotators = {}

        -- create rotators
        for boneNumber, bone in self.EngineBones do
            self.EngineRotators[bone] = CreateRotator(self, bone, 'z', 0, 30)
        end
    end,

    ---@param self XNL0402
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
    OnMotionHorzEventChange = function(self, new, old)
        NLandUnit.OnMotionHorzEventChange(self, new, old)
        --rotate the engine bones based on the speed of the unit
        local goal = 0
        if new == 'TopSpeed' then goal = 30 end

        for boneName, rotator in self.EngineRotators do
            if boneName == 'FrontEngineBlock01' or boneName == 'FrontEngineBlock02' then
                rotator:SetGoal(goal*0.3)
            else
                rotator:SetGoal(goal)
            end
        end
    end,

    ---@param self XNL0402
    OnDestroy = function(self)
        if not self.BeamDisableThread then
            self.BeamDisableThread = self:ForkThread( self.BeamEffectsDisableThread )
        end
        NLandUnit.OnDestroy(self)
    end,

    ---@param self XNL0402
    ---@param Weapon string
    OnGotTarget = function(self, Weapon)
        NLandUnit.OnGotTarget(self, Weapon)
        --in case we are disabling the beam effects, cancel the thread instead of recreating
        if self.BeamDisableThread then
            KillThread(self.BeamDisableThread)
            self.BeamDisableThread = nil
        else
            self:PlayFakeBeamEffects()
        end
        self.Beaming = true
        if self.AnimationManipulator and not self.Dead then
            self.AnimationManipulator:SetRate(0.8)
        end
    end,

    ---@param self XNL0402
    ---@param Weapon string
    OnLostTarget = function(self, Weapon)
        NLandUnit.OnLostTarget(self, Weapon)
        if not self.BeamDisableThread and self.Beaming then
            self.BeamDisableThread = self:ForkThread( self.BeamEffectsDisableThread )
        end
        self.Beaming = false
        if self.AnimationManipulator and not self.Dead then
            self.AnimationManipulator:SetRate(-0.5)
        end
    end,

    ---@param self XNL0402
    PlayBeamChargeUpSequence = function(self)
        -- plays the flashing effects at the body
        local fn = function(self)
            local emitrate, emitters, emit = 0, {}, nil
            for k, v in NomadsEffectTemplate.PhaseRayChargeUpFxPerm do
                emit = CreateAttachedEmitterColoured(self, 'ReactorBeam02', self.Army, v)--:OffsetEmitter(0, 0.1, 0) --flashing light
                table.insert( emitters, emit )
                self.BeamChargeUpFxBag:Add( emit )
                self.Trash:Add( emit )
            end
            while self do
                emitrate = self.BeamChargeupEffectScale or 1
                emitrate = (emitrate * 10) * emitrate
                for k, emit in emitters do
                    emit:SetEmitterCurveParam('EMITRATE_CURVE', emitrate, 0)
                end
                WaitTicks(1)
            end
        end

        local thread = self:ForkThread( fn )
        self.BeamChargeUpFxBag:Add( thread )
    end,

    ---@param self XNL0402
    PlayFakeBeamEffects = function(self)
        -- this is just for the beam that emits from the unit body to the 'mirror' on floating above the unit

        -- play charge up sound, but only when it should
        local bp = self.Blueprint
        if bp.Audio.ChargeBeam then
            self:PlaySound(bp.Audio.ChargeBeam)
        end

        self.BeamHelperFxBag:Destroy() --clear any existing effects in case of stacking
        local emit, beam = nil, nil
        for k, v in NomadsEffectTemplate.PhaseRayFakeBeamMuzzle do
            emit = CreateAttachedEmitterColoured( self, 'ReactorBeam01', self.Army, v )--:OffsetEmitter(0, 0.1, 0)
            self.BeamHelperFxBag:Add( emit )
            self.Trash:Add( emit )
        end

        -- create a beam between the body of the unit and the tiny aimer thing
        for k, v in NomadsEffectTemplate.PhaseRayFakeBeam do
            local beamBp = RenameBeamEmitterToColoured(v,self.ColourIndex) --our beam is coloured so we recolour the emitter as well.
            beam = AttachBeamEntityToEntity(self, 'ReactorBeam01', self, "ReactorBeam02", self.Army, beamBp )
            self.BeamHelperFxBag:Add( beam )
            self.Trash:Add( beam )
        end
    end,

    --wait time needed to allow the beamer to retarget without the fake beam being turned on and off all the time
    --currently this relies on completing everything instantly after the wait time. if this changes, more thinking is needed
    ---@param self XNL0402
    BeamEffectsDisableThread = function(self)
        WaitTicks(20)
        self.BeamHelperFxBag:Destroy()
        self.BeamChargeUpFxBag:Destroy()
        if self.Beaming then
            for k, v in NomadsEffectTemplate.PhaseRayFakeBeamMuzzleBeamingStopped do
                emit = CreateAttachedEmitterColoured( self, 'ReactorBeam01', self.Army, v )
            end
        end
        
        self.BeamDisableThread = nil
    end,

    ---@param self XNL0402
    ---@param transport Unit
    ---@param bone Bone
    OnStartTransportBeamUp = function(self, transport, bone)
        NLandUnit.OnStartTransportBeamUp(self, transport, bone)
        self:MarkWeaponsOnTransport(true) --mark the weapons early so that the animation finishes faster.
    end,

    ---@param self XNL0402
    TransportBeamThread = function(self)
        NLandUnit.TransportBeamThread(self)
        if not self.InTransport and self.TransAnimation and self.TransAnimThread then
            self:MarkWeaponsOnTransport(false)
        end
    end,

    -- Destroy the beam effects if the beam is on, so it doesnt stay on while sinking.
    ---@param self XNL0402
    ---@param instigator Unit
    ---@param damageType DamageType
    ---@param overkillRatio number
    OnKilled = function(self, instigator, damageType, overkillRatio)
        self:ForkThread(self.BeamDestructionDeathThread)
        NLandUnit.OnKilled(self, instigator, damageType, overkillRatio)
    end,

    --We fork the thread to avoid the death script fucking up if it goes wrong
    ---@param self XNL0402
    BeamDestructionDeathThread = function(self)
        if self.GetWeapon then
            local wep = self:GetWeapon(1)
            if wep.Beams then
                WaitTicks(20)
                if wep.Audio.BeamLoop and wep.Beams[1].Beam then
                    wep.Beams[1].Beam:SetAmbientSound(nil, nil)
                end
                for k, v in wep.Beams do
                    v.Beam:Disable()
                end
            end
        end
    end,

    ---@param self XNL0402
    ---@param overkillRatio number
    ---@param instigator Unit unused
    DeathThread = function( self, overkillRatio, instigator)
        -- slightly inspired by the monkeylords effect

        self:PlayUnitSound('Killed')

        -- Create Initial explosion effects
        Explosion.CreateFlash( self, 'ReactorBeam01', 2, self.Army )
        CreateAttachedEmitter(self, 0, self.Army, '/effects/emitters/explosion_fire_sparks_02_emit.bp')
        CreateAttachedEmitter(self, 0, self.Army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.2)
        self:ShakeCamera(30, 4, 0, 1)

        self:CreateExplosionDebris( 0, self.Army )

        -- damage ring to push trees
        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        WaitTicks( Random(2, 8) )
        -- some more explosions
        local numBones = self:GetBoneCount() - 1
        for i=Random(1,3), 3 do
            local bone = Random( 0, numBones )
            Explosion.CreateDefaultHitExplosionAtBone( self, bone, RandomFloat( 1.0, 2.0) )
            self:CreateExplosionDebris( bone, self.Army )
            WaitTicks( 13 - i - Random(0, 2) )
        end

        -- final explosion
        Explosion.CreateFlash( self, 0, 3, self.Army )
        self:ShakeCamera(2.5, 1.25, 0, 0.15)
        self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris( 0, self.Army )
        self:CreateExplosionDebris( 0, self.Army )

        -- Finish up force ring to push trees
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        if self:ShallSink() then
            self.DisallowCollisions = true

            -- Bubbles and stuff coming off the sinking wreck.
            self:ForkThread(self.SinkDestructionEffects)

            -- Avoid slightly ugly need to propagate this through callback hell...
            self.overkillRatio = overkillRatio

            -- A non-naval unit or boat with no sinking animation dying over water needs to sink, but lacks an animation for it. Let's make one up.
            local this = self
            self:StartSinking(
                function()
                    this:DestroyUnit(overkillRatio)
                end
            )

            -- Wait for the sinking callback to actually destroy the unit.
            return
        end

        self:DestroyUnit(overkillRatio)
    end,

    ---@param self XNL0402
    ---@param bone Bone
    ---@param army Army
    CreateExplosionDebris = function( self, bone, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
}
TypeClass = XNL0402