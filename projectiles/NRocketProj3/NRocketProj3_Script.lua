-- a rocket that has the effects of missiles

local Rocket1 = import('/lua/nomadsprojectiles.lua').Rocket1
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NRocketProj3 = Class(Rocket1) {
    BeamName = NomadsEffectTemplate.MissileBeam,

    FxImpactAirUnit = NomadsEffectTemplate.MissileHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.MissileHitLand1,
    FxImpactNone = NomadsEffectTemplate.MissileHitNone1,
    FxImpactProp = NomadsEffectTemplate.MissileHitProp1,
    FxImpactShield = NomadsEffectTemplate.MissileHitShield1,
    FxImpactUnit = NomadsEffectTemplate.MissileHitUnit1,
    FxImpactWater = NomadsEffectTemplate.MissileHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.MissileHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.MissileHitUnderWater1,
    FxTrails = NomadsEffectTemplate.MissileTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadsEffectTemplate.MissilePolyTrail,
    PolyTrailOffset = 0,
}
TypeClass = NRocketProj3
