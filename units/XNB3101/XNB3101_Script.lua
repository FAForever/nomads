local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

--- Tech 1 Radar
---@class XNB3101 : NRadarUnit
XNB3101 = Class(NRadarUnit) {

    IntelBoostFxBone = 'Blinklight',
    OverchargeExplosionFxBone = 0,

    IntelBoostFx = NomadsEffectTemplate.T1RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T1RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T1RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T1RadarOverchargeExplosion,
}
TypeClass = XNB3101