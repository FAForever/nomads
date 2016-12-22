local TacticalMissile = import('/lua/nomadprojectiles.lua').TacticalMissile
local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')

NTacticalMissile1 = Class(TacticalMissile) {
    FxImpactAirUnit = NomadEffectTemplate.TacticalMissileHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.TacticalMissileHitLand2,
    FxImpactNone = NomadEffectTemplate.TacticalMissileHitNone2,
    FxImpactProp = NomadEffectTemplate.TacticalMissileHitProp2,
    FxImpactShield = NomadEffectTemplate.TacticalMissileHitShield2,
    FxImpactUnit = NomadEffectTemplate.TacticalMissileHitUnit2,
    FxImpactWater = NomadEffectTemplate.TacticalMissileHitWater2,
    FxImpactProjectile = NomadEffectTemplate.TacticalMissileHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.TacticalMissileHitUnderWater2,
}

TypeClass = NTacticalMissile1
