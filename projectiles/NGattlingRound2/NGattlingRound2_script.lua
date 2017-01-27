local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local GattlingRound = import('/lua/nomadsprojectiles.lua').GattlingRound

NGattlingRound2 = Class(GattlingRound) {

    FxImpactAirUnit = NomadsEffectTemplate.GattlingHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.GattlingHitLand2,
    FxImpactNone = NomadsEffectTemplate.GattlingHitNone2,
    FxImpactProp = NomadsEffectTemplate.GattlingHitProp2,
    FxImpactShield = NomadsEffectTemplate.GattlingHitShield2,
    FxImpactUnit = NomadsEffectTemplate.GattlingHitUnit2,
    FxImpactWater = NomadsEffectTemplate.GattlingHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.GattlingHitProjectile2,

    FxTrails = NomadsEffectTemplate.GattlingTrail2,
    PolyTrails = NomadsEffectTemplate.GattlingPolyTrails2,
    PolyTrailOffset = {0,0,0,0},
}

TypeClass = NGattlingRound2
