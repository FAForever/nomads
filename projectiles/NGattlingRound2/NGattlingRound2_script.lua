local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local GattlingRound = import('/lua/nomadprojectiles.lua').GattlingRound

NGattlingRound2 = Class(GattlingRound) {

    FxImpactAirUnit = NomadEffectTemplate.GattlingHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.GattlingHitLand2,
    FxImpactNone = NomadEffectTemplate.GattlingHitNone2,
    FxImpactProp = NomadEffectTemplate.GattlingHitProp2,
    FxImpactShield = NomadEffectTemplate.GattlingHitShield2,
    FxImpactUnit = NomadEffectTemplate.GattlingHitUnit2,
    FxImpactWater = NomadEffectTemplate.GattlingHitWater2,
    FxImpactProjectile = NomadEffectTemplate.GattlingHitProjectile2,

    FxTrails = NomadEffectTemplate.GattlingTrail2,
    PolyTrails = NomadEffectTemplate.GattlingPolyTrails2,
    PolyTrailOffset = {0,0,0,0},
}

TypeClass = NGattlingRound2
