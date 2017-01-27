local TacticalMissile = import('/lua/nomadsprojectiles.lua').TacticalMissile
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NTacticalMissile1 = Class(TacticalMissile) {
    FxImpactAirUnit = NomadsEffectTemplate.TacticalMissileHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.TacticalMissileHitLand2,
    FxImpactNone = NomadsEffectTemplate.TacticalMissileHitNone2,
    FxImpactProp = NomadsEffectTemplate.TacticalMissileHitProp2,
    FxImpactShield = NomadsEffectTemplate.TacticalMissileHitShield2,
    FxImpactUnit = NomadsEffectTemplate.TacticalMissileHitUnit2,
    FxImpactWater = NomadsEffectTemplate.TacticalMissileHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.TacticalMissileHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.TacticalMissileHitUnderWater2,
}

TypeClass = NTacticalMissile1
