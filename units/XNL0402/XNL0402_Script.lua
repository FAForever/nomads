-- experimental beam tank

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local NDFPlasmaBeamWeapon = import('/lua/nomadsweapons.lua').NDFPlasmaBeamWeapon
local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

XNL0402 = Class(NLandUnit) {

    Weapons = {
        MainGun = Class(NDFPlasmaBeamWeapon) {},
        MainGunTransported = Class(NDFPlasmaBeamWeapon) {},
    },

    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self.Beaming = false
        self.BeamChargeUpFxBag = TrashBag()
        self.BeamHelperFxBag = TrashBag()
    end,

    OnDestroy = function(self)
        self:DestroyBeamChargeUpEffects()
        self:DestroyFakeBeamEffects()
        NLandUnit.OnDestroy(self)
    end,

    OnDetachedFromTransport = function(self, transport, transportBone)
        NLandUnit.OnDetachedFromTransport(self, transport, transportBone)

        -- reset weapon in case it was firing from transport
        local wep = self:GetWeaponByLabel('MainGunTransported')
        if wep and self.Beaming then
            wep.AllowBeamShutdown = true
            wep:PlayFxBeamEnd()
            wep:ResetTarget()
        end
    end,

    PlayBeamChargeUpSequence = function(self)
        -- plays the flashing effects at the body
        local fn = function(self)
            local army, emitrate, emitters, emit = self:GetArmy(), 0, {}, nil
            for k, v in NomadsEffectTemplate.PhaseRayChargeUpFxPerm do
                emit = CreateAttachedEmitter(self, 'ReactorBeam01', army, v):OffsetEmitter(0, 0.1, 0)
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

    ScaleBeamChargeupEffects = function(self, scale)
        self.BeamChargeupEffectScale = scale
    end,

    DestroyBeamChargeUpEffects = function(self)
        self.BeamChargeUpFxBag:Destroy()
    end,

    PlayFakeBeamEffects = function(self)
        -- this is just for the beam that emits from the unit body to the 'mirror' on floating above the unit

        local army, emit, beam = self:GetArmy(), nil, nil
        for k, v in NomadsEffectTemplate.PhaseRayFakeBeamMuzzle do
            emit = CreateAttachedEmitter( self, 'TurretYaw', army, v ):OffsetEmitter(0, 0.1, 0)
            self.BeamHelperFxBag:Add( emit )
            self.Trash:Add( emit )
        end

        -- create a beam between the body of the unit and the tiny aimer thing
        for k, v in NomadsEffectTemplate.PhaseRayFakeBeam do
            beam = AttachBeamEntityToEntity(self, 'ReactorBeam01', self, "XNL0402", army, v )
            self.BeamHelperFxBag:Add( beam )
            self.Trash:Add( beam )
        end
    end,

    DestroyFakeBeamEffects = function(self)
        self.BeamHelperFxBag:Destroy()
        if self.Beaming then
            self:PlayAfterBeamEffects()
        end
    end,

    PlayAfterBeamEffects = function(self)
        local army = self:GetArmy()
        for k, v in NomadsEffectTemplate.PhaseRayFakeBeamMuzzleBeamingStopped do
            emit = CreateAttachedEmitter( self, 'ReactorBeam01', army, v ):OffsetEmitter(0, 0.1, 0)
        end
    end,

    -- ---------------------------------------------------------------------------------------------------------------

    DeathThread = function( self, overkillRatio, instigator)
        if self.Beaming then
            self:DeathExplosionsThreadImmediate( overkillRatio )
        else
            self:DeathExplosionsThread( overkillRatio )
        end
    end,

    DeathExplosionsThreadImmediate = function(self, overkillRatio)

        self:PlayUnitSound('Killed')
        local army = self:GetArmy()

        -- extra effect: explosion at the thingy that redirects the beam
        if self.Beaming then
            Explosion.CreateDefaultHitExplosionAtBone(self, 'TurretPitch', 0.5 )
            self:HideBone( 'TurretPitch', false)
        end

        WaitTicks( Random(2, 3) )

        -- Create Initial explosion effects
        Explosion.CreateFlash( self, 'ReactorBeam01', 3, army )
        CreateAttachedEmitter(self, 0, army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(0.5)
        CreateAttachedEmitter(self, 0, army, '/effects/emitters/explosion_fire_sparks_02_emit.bp')
        CreateAttachedEmitter(self, 0, army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.5)
        self:ShakeCamera(50, 5, 0, 1)

        self:CreateExplosionDebris( 0, army )
        self:CreateExplosionDebris( 0, army )
        self:CreateExplosionDebris( 0, army )

        -- damage ring to push trees
        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        -- create wreckage
        self:CreateWreckage(overkillRatio)

        self:Destroy()
    end,

    DeathExplosionsThread = function( self, overkillRatio)
        -- slightly inspired by the monkeylords effect

        self:PlayUnitSound('Killed')
        local army = self:GetArmy()

        -- Create Initial explosion effects
        Explosion.CreateFlash( self, 'ReactorBeam01', 2, army )
        CreateAttachedEmitter(self, 0, army, '/effects/emitters/explosion_fire_sparks_02_emit.bp')
        CreateAttachedEmitter(self, 0, army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.2)
        self:ShakeCamera(30, 4, 0, 1)

        self:CreateExplosionDebris( 0, army )

        -- damage ring to push trees
        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        WaitTicks( Random(2, 8) )

        -- some more explosions
        local numBones = self:GetBoneCount() - 1
        for i=Random(1,3), 5 do
            local bone = Random( 0, numBones )
            Explosion.CreateDefaultHitExplosionAtBone( self, bone, RandomFloat( 1.0, 2.0) )
            self:CreateExplosionDebris( bone, army )
            WaitTicks( 13 - i - Random(0, 2) )
        end

        -- final explosion
        Explosion.CreateFlash( self, 0, 3, army )
        self:ShakeCamera(2.5, 1.25, 0, 0.15)
        self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris( 0, army )
        self:CreateExplosionDebris( 0, army )

        -- Finish up force ring to push trees
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        -- create wreckage
        self:CreateWreckage(overkillRatio)

        self:Destroy()
    end,

    CreateExplosionDebris = function( self, bone, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
}

TypeClass = XNL0402