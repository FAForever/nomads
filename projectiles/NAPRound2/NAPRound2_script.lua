local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local APRound = import('/lua/nomadprojectiles.lua').APRound

NAPRound2 = Class(APRound) {

    FxImpactAirUnit = NomadEffectTemplate.APCannonHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.APCannonHitLand2,
    FxImpactNone = NomadEffectTemplate.APCannonHitNone2,
    FxImpactProp = NomadEffectTemplate.APCannonHitProp2,
    FxImpactShield = NomadEffectTemplate.APCannonHitShield2,
    FxImpactUnit = NomadEffectTemplate.APCannonHitUnit2,
    FxImpactWater = NomadEffectTemplate.APCannonHitWater2,
    FxImpactProjectile = NomadEffectTemplate.APCannonHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.APCannonHitUnderWater2,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadEffectTemplate.APCannonTrail2,
    PolyTrail = NomadEffectTemplate.APCannonPolyTrail2,
}

TypeClass = NAPRound2