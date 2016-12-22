local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local Missile1 = import('/lua/nomadprojectiles.lua').Missile1

NMissileProj2 = Class(Missile1) {
    FxImpactAirUnit = NomadEffectTemplate.MissileHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.MissileHitLand2,
    FxImpactNone = NomadEffectTemplate.MissileHitNone2,
    FxImpactProp = NomadEffectTemplate.MissileHitProp2,
    FxImpactShield = NomadEffectTemplate.MissileHitShield2,
    FxImpactUnit = NomadEffectTemplate.MissileHitUnit2,
    FxImpactWater = NomadEffectTemplate.MissileHitWater2,
    FxImpactProjectile = NomadEffectTemplate.MissileHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.MissileHitUnderWater2,
}

TypeClass = NMissileProj2