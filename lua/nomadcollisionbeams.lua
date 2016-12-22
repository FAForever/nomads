local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local NomadEffectTemplate = import ('/lua/nomadeffecttemplate.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')
local Util = import('/lua/utilities.lua')


# Nomads continuous beam
NomadPhaseRay = Class(CollisionBeam) {

    # The only beam in the Nomads mod!
    # there was some crazy stuff in here that would allow healing of units. This never seemed to work and since I don't care
    # for healing units (we're removing the fancy stuff remember!) it got deleted.

    FxBeamStartPoint = NomadEffectTemplate.PhaseRayMuzzle,
    FxBeam = NomadEffectTemplate.PhaseRayBeam,
    FxBeamEndPoint = NomadEffectTemplate.PhaseRayBeamEnd,
    FxImpactAirUnit = NomadEffectTemplate.PhaseRayHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.PhaseRayHitLand1,
    FxImpactNone = NomadEffectTemplate.PhaseRayHitNone1,
    FxImpactProp = NomadEffectTemplate.PhaseRayHitProp1,
    FxImpactShield = NomadEffectTemplate.PhaseRayHitShield1,
    FxImpactUnit = NomadEffectTemplate.PhaseRayHitUnit1,
    FxImpactWater = NomadEffectTemplate.PhaseRayHitWater1,
    FxImpactProjectile = NomadEffectTemplate.PhaseRayHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.PhaseRayHitUnderWater1,
    ScorchSplatDropTime = 0.25,
    SplatTexture = 'czar_mark01_albedo',
    TerrainImpactScale = 1,
    TerrainImpactType = 'LargeBeam01',

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
        local army = self:GetArmy()
        local size = 1.2 + (Random() * 1.5)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors( CurrentPosition, LastPosition ) > 0.25 or skipCount > 100 then

                # only create splat if it makes sense to make one on the surface
                if impactType != 'Air' and impactType != 'Nothing' then
                    CreateSplat( CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army )
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

# Nomads beam cannon
NomadPhaseRayCannon = Class(NomadPhaseRay) {
    FxBeamStartPoint = NomadEffectTemplate.PhaseRayCannonMuzzle,
    FxBeam = NomadEffectTemplate.PhaseRayBeamCannon,
    FxBeamEndPoint = NomadEffectTemplate.PhaseRayCannonBeamEnd,
    FxImpactAirUnit = NomadEffectTemplate.PhaseRayCannonHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.PhaseRayCannonHitLand1,
    FxImpactNone = NomadEffectTemplate.PhaseRayCannonHitNone1,
    FxImpactProp = NomadEffectTemplate.PhaseRayCannonHitProp1,
    FxImpactShield = NomadEffectTemplate.PhaseRayCannonHitShield1,
    FxImpactUnit = NomadEffectTemplate.PhaseRayCannonHitUnit1,
    FxImpactWater = NomadEffectTemplate.PhaseRayCannonHitWater1,
    FxImpactProjectile = NomadEffectTemplate.PhaseRayCannonHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.PhaseRayCannonHitUnderWater1,
}
