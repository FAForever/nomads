local KineticRound = import('/lua/nomadprojectiles.lua').KineticRound
local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')

NKineticRound2 = Class(KineticRound) {
    FxImpactAirUnit = NomadEffectTemplate.KineticCannonHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.KineticCannonHitLand2,
    FxImpactNone = NomadEffectTemplate.KineticCannonHitNone2,
    FxImpactProp = NomadEffectTemplate.KineticCannonHitProp2,
    FxImpactShield = NomadEffectTemplate.KineticCannonHitShield2,
    FxImpactUnit = NomadEffectTemplate.KineticCannonHitUnit2,
    FxImpactWater = NomadEffectTemplate.KineticCannonHitWater2,
    FxImpactProjectile = NomadEffectTemplate.KineticCannonHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.KineticCannonHitUnderWater2,

    FxImpactTrajectoryAligned = false,
    PolyTrail = NomadEffectTemplate.KineticCannonPolyTrail2,
}

TypeClass = NKineticRound2