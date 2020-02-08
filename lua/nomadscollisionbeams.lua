local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local SCCollisionBeam = import('/lua/defaultcollisionbeams.lua').SCCollisionBeam
local NomadsEffectTemplate = import ('/lua/nomadseffecttemplate.lua')
local Util = import('/lua/utilities.lua')

-- TODO:possibly put the CollisionBeam hook into this one instead, no need to hook all the beams just because?
-- Nomads continuous beam
NomadsPhaseRay = Class(CollisionBeam) {
    -- The only beam in the Nomads mod!
    -- there was some crazy stuff in here that would allow healing of units. This never seemed to work and since I don't care
    -- for healing units (we're removing the fancy stuff remember!) it got deleted.
    FxBeamStartPoint = NomadsEffectTemplate.PhaseRayMuzzle,
    FxBeam = NomadsEffectTemplate.PhaseRayBeam,
    FxBeamEndPoint = NomadsEffectTemplate.PhaseRayBeamEnd,
    FxImpactAirUnit = NomadsEffectTemplate.PhaseRayHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.PhaseRayHitLand1,
    FxImpactNone = NomadsEffectTemplate.PhaseRayHitNone1,
    FxImpactProp = NomadsEffectTemplate.PhaseRayHitProp1,
    FxImpactShield = NomadsEffectTemplate.PhaseRayHitShield1,
    FxImpactUnit = NomadsEffectTemplate.PhaseRayHitUnit1,
    FxImpactWater = NomadsEffectTemplate.PhaseRayHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.PhaseRayHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.PhaseRayHitUnderWater1,
    ScorchSplatDropTime = 0.25,
    SplatTexture = 'czar_mark01_albedo',
    TerrainImpactScale = 1,
    TerrainImpactType = 'LargeBeam01',

    EmittersToRecolour = {'FxBeam',},
    FactionColour = true,

    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread( self.ScorchThread, impactType )
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    OnDisable = function( self )
        KillThread(self.Scorching)
        self.Scorching = nil
        CollisionBeam.OnDisable(self)
    end,

    ScorchThread = function(self, impactType)
        local size = 1.2 + (Random() * 1.5)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors( CurrentPosition, LastPosition ) > 0.25 or skipCount > 100 then

                -- only create splat if it makes sense to make one on the surface
                if impactType ~= 'Air' and impactType ~= 'Nothing' then
                    CreateSplat( CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, self.Army )
                end

                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds( self.ScorchSplatDropTime )
            size = 1.2 + (Random() * 1.5)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

-- Nomads beam cannon
NomadsPhaseRayCannon = Class(NomadsPhaseRay) {
    FxBeamStartPoint = NomadsEffectTemplate.PhaseRayCannonMuzzle,
    FxBeam = NomadsEffectTemplate.PhaseRayBeamCannon,
    FxBeamEndPoint = NomadsEffectTemplate.PhaseRayCannonBeamEnd,
    FxImpactAirUnit = NomadsEffectTemplate.PhaseRayCannonHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.PhaseRayCannonHitLand1,
    FxImpactNone = NomadsEffectTemplate.PhaseRayCannonHitNone1,
    FxImpactProp = NomadsEffectTemplate.PhaseRayCannonHitProp1,
    FxImpactShield = NomadsEffectTemplate.PhaseRayCannonHitShield1,
    FxImpactUnit = NomadsEffectTemplate.PhaseRayCannonHitUnit1,
    FxImpactWater = NomadsEffectTemplate.PhaseRayCannonHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.PhaseRayCannonHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.PhaseRayCannonHitUnderWater1,
}

HVFlakCollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {
        '/effects/emitters/targeting_beam_invisible.bp'
    },
    FxBeamEndPoint = NomadsEffectTemplate.MissileHitNone1,
}

