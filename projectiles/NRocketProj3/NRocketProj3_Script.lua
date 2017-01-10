-- a rocket that has the effects of missiles

local Rocket1 = import('/lua/nomadprojectiles.lua').Rocket1
local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')

NRocketProj3 = Class(Rocket1) {
    BeamName = NomadEffectTemplate.MissileBeam,

    FxImpactAirUnit = NomadEffectTemplate.MissileHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.MissileHitLand1,
    FxImpactNone = NomadEffectTemplate.MissileHitNone1,
    FxImpactProp = NomadEffectTemplate.MissileHitProp1,
    FxImpactShield = NomadEffectTemplate.MissileHitShield1,
    FxImpactUnit = NomadEffectTemplate.MissileHitUnit1,
    FxImpactWater = NomadEffectTemplate.MissileHitWater1,
    FxImpactProjectile = NomadEffectTemplate.MissileHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.MissileHitUnderWater1,
    FxTrails = NomadEffectTemplate.MissileTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadEffectTemplate.MissilePolyTrail,
    PolyTrailOffset = 0,
}
TypeClass = NRocketProj3
