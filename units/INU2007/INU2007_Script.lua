-- experimental beam tank

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local PhaseRayGun = import('/lua/nomadsweapons.lua').PhaseRayGun
local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

INU2007 = Class(NLandUnit) {

    Weapons = {
        MainGun = Class(PhaseRayGun) {
            -- unfortunately this code is too specific to be put in a generic class

            DoChargeUpEffects = function(self)
                -- this plays when the unit packs and unpacks, so both directions
                local fn = function(self)
                    local frac, oldfrac = 0, -1
                    if self.UnpackAnimator then frac = self.UnpackAnimator:GetAnimationFraction() end
                    self.unit:PlayBeamChargeUpSequence()
                    self.unit:ScaleBeamChargeupEffects( frac )
                    while self and self.unit and not self.unit:IsDead() do
                        if self.UnpackAnimator then
                            frac = self.UnpackAnimator:GetAnimationFraction()
                            self.unit:ScaleBeamChargeupEffects( math.min(frac, 1) )
                            if (frac >= 1 and oldfrac < frac) or (frac <= 0 and oldfrac > frac) then break end
                            oldfrac = frac
                        end
                        WaitTicks(1)
                    end
                    if frac < 1 then  -- leaving the effects cleaned up by another process if we're charging up
                        self.unit:DestroyBeamChargeUpEffects()
                    end
                end
                self.unit.BeamHelperFxBag:Add( self:ForkThread( fn ) )
            end,

            PlayFxBeamStart = function(self, muzzle)

                local beam = false
                for k, v in self.Beams do   -- find beam
                    if v.Muzzle == muzzle then
                        beam = v.Beam
                        break
                    end
                end

                if beam and not beam:IsEnabled() then  -- beam exists but is not active

                    -- ativate beam
                    beam:Enable()
                    self.unit.Trash:Add(beam)
                    self.unit.Beaming = true
                    self.AllowBeamShutdown = false

                    -- additional effects
                    self.unit:DestroyBeamChargeUpEffects()
                    self.unit:PlayFakeBeamEffects()
                    local bp = self:GetBlueprint()
                    if bp.Audio.BeamStart then self:PlaySound(bp.Audio.BeamStart) end
                    if bp.Audio.BeamLoop and self.Beams[1].Beam then self.Beams[1].Beam:SetAmbientSound(bp.Audio.BeamLoop, nil) end

                    -- check for hold fire
                    if not bp.ContinuousBeam and bp.BeamLifetime > 0 then
                        self:ForkThread( self.BeamLifetimeThread, beam, bp.BeamLifetime or 1)
                    else
                        self.HoldFireThread = self:ForkThread(self.WatchForHoldFire, beam)
                    end

                elseif beam then  -- nothing to do
                    return

                else  -- no beam exist, error
                    error('*ERROR: We have a beam created that does not coincide with a muzzle bone.  Internal Error, aborting beam weapon.', 2)
                end
            end,

            PlayFxBeamEnd = function(self, beam)

                -- only allow shutting down the beam if the lifetime is exceeded or hold fire was used. If we don't do this the beam
                -- shuts down each time the target assigned by the player is killed. The unit then waits a while before starting the
                -- beam again.
                if not self.AllowBeamShutdown and self.unit and not self.unit:IsDead() then return end

                if self.HoldFireThread then
                    KillThread( self.HoldFireThread )
                end

                -- destroy unit effects and beam
                self.unit:DestroyBeamChargeUpEffects()
                self.unit:DestroyFakeBeamEffects()
                local bp = self:GetBlueprint()
                if bp.Audio.BeamStop and self.unit.Beaming then self:PlaySound(bp.Audio.BeamStop) end
                if bp.Audio.BeamLoop and self.Beams[1].Beam then self.Beams[1].Beam:SetAmbientSound(nil, nil) end

                -- find current beam(s) and disable them
                if beam then
                    beam:Disable()
                else
                    for k, v in self.Beams do
                        v.Beam:Disable()
                    end
                end
                self.unit.Beaming = false
            end,

            BeamLifetimeThread = function(self, beam, lifeTime)  -- this is used for a beams lifetime, modified to set the allowbeamshutdown flag
                WaitSeconds(lifeTime)
                self.AllowBeamShutdown = true
                self:PlayFxBeamEnd(beam)
            end,

            WatchForHoldFire = function(self, beam)  -- modified to set the allowbeamshutdown flag
                while true do
                    WaitSeconds(1)
                    if self.unit and self.unit:GetFireState() == 1 then   --if we're at hold fire, stop beam
                        self.BeamStarted = false
                        self.AllowBeamShutdown = true
                        self:PlayFxBeamEnd(beam)
                    end
                end
            end,

            PlayFxWeaponUnpackSequence = function(self)
                -- this is forked by another process. Injecting the charge up effect.
                self:DoChargeUpEffects()

                -- play charge up sound, but only when it should
                local bp = self:GetBlueprint()
                if bp.Audio.ChargingBeam and not self.ChargeSoundPlayed and (not self.UnpackAnimator or self.UnpackAnimator:GetAnimationFraction() <= 0.1) then
                    self:PlaySound(bp.Audio.ChargingBeam)
                    self.ChargeSoundPlayed = true
                end

                PhaseRayGun.PlayFxWeaponUnpackSequence(self)

                -- default script bug fix: it doesn't handle properly if we're packing when this function is called. Making
                -- sure we unpack before firing. Also requires the code in WeaponUnpackingState
                if self.UnpackAnimator then
                    self.UnpackAnimator:SetRate(bp.WeaponUnpackAnimationRate)
                    WaitFor(self.UnpackAnimator)
                    self.ChargeSoundPlayed = false
                end
            end,

            WeaponUnpackingState = State(PhaseRayGun.WeaponUnpackingState) {
                Main = function(self)
                    -- the next line is also part of the bug fix mentioned in PlayFxWeaponUnpackSequence()
                    self:PlayFxWeaponUnpackSequence()
                    return PhaseRayGun.WeaponUnpackingState.Main(self)
                end,
            },

            WeaponPackingState = State(PhaseRayGun.WeaponPackingState) {
                 -- shut down beam before packing up
                 Main = function(self)
                    WaitTicks(1)   -- wait a tick before shutting down the beam, in case we suddenly have another target
                    self.AllowBeamShutdown = true
                    self:PlayFxBeamEnd(self.Beams[1].Beam)
                    return PhaseRayGun.WeaponPackingState.Main(self)
                end,
            },
        },
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
        local wep = self:GetWeaponByLabel('MainGun')
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
                emit = CreateAttachedEmitter(self, 'circle', army, v):OffsetEmitter(0, 0.1, 0)
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
            emit = CreateAttachedEmitter( self, 'beamstart', army, v ):OffsetEmitter(0, 0.1, 0)
            self.BeamHelperFxBag:Add( emit )
            self.Trash:Add( emit )
        end

        -- create a beam between the body of the unit and the tiny aimer thing
        for k, v in NomadsEffectTemplate.PhaseRayFakeBeam do
            beam = AttachBeamEntityToEntity(self, 'circle', self, "aim", army, v )
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
            emit = CreateAttachedEmitter( self, 'circle', army, v ):OffsetEmitter(0, 0.1, 0)
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
            Explosion.CreateDefaultHitExplosionAtBone(self, 'drone', 0.5 )
            self:HideBone( 'drone', false)
        end

        WaitTicks( Random(2, 3) )

        -- Create Initial explosion effects
        Explosion.CreateFlash( self, 'beamstart', 3, army )
        CreateAttachedEmitter(self, 'INU2007', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(0.5)
        CreateAttachedEmitter(self, 'INU2007', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp')
        CreateAttachedEmitter(self, 'INU2007', army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.5)
        self:ShakeCamera(50, 5, 0, 1)

        self:CreateExplosionDebris( 'INU2007', army )
        self:CreateExplosionDebris( 'INU2007', army )
        self:CreateExplosionDebris( 'INU2007', army )

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
        Explosion.CreateFlash( self, 'beamstart', 2, army )
        CreateAttachedEmitter(self, 'INU2007', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp')
        CreateAttachedEmitter(self, 'INU2007', army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.2)
        self:ShakeCamera(30, 4, 0, 1)

        self:CreateExplosionDebris( 'INU2007', army )

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
        Explosion.CreateFlash( self, 'INU2007', 3, army )
        self:ShakeCamera(2.5, 1.25, 0, 0.15)
        self:PlayUnitSound('Destroyed')

        self:CreateExplosionDebris( 'INU2007', army )
        self:CreateExplosionDebris( 'INU2007', army )

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

TypeClass = INU2007