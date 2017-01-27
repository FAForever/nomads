local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Missile1 = import('/lua/nomadsprojectiles.lua').Missile1

NMissileProj2 = Class(Missile1) {
    FxImpactAirUnit = NomadsEffectTemplate.MissileHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.MissileHitLand2,
    FxImpactNone = NomadsEffectTemplate.MissileHitNone2,
    FxImpactProp = NomadsEffectTemplate.MissileHitProp2,
    FxImpactShield = NomadsEffectTemplate.MissileHitShield2,
    FxImpactUnit = NomadsEffectTemplate.MissileHitUnit2,
    FxImpactWater = NomadsEffectTemplate.MissileHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.MissileHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.MissileHitUnderWater2,
}

TypeClass = NMissileProj2