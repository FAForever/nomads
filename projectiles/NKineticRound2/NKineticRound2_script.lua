local KineticRound = import('/lua/nomadsprojectiles.lua').KineticRound
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NKineticRound2 = Class(KineticRound) {
    FxImpactAirUnit = NomadsEffectTemplate.KineticCannonHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.KineticCannonHitLand2,
    FxImpactNone = NomadsEffectTemplate.KineticCannonHitNone2,
    FxImpactProp = NomadsEffectTemplate.KineticCannonHitProp2,
    FxImpactShield = NomadsEffectTemplate.KineticCannonHitShield2,
    FxImpactUnit = NomadsEffectTemplate.KineticCannonHitUnit2,
    FxImpactWater = NomadsEffectTemplate.KineticCannonHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.KineticCannonHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.KineticCannonHitUnderWater2,

    FxImpactTrajectoryAligned = false,
    PolyTrail = NomadsEffectTemplate.KineticCannonPolyTrail2,
}

TypeClass = NKineticRound2